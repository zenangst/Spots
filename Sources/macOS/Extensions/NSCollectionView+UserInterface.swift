// swiftlint:disable large_tuple
import Cocoa

extension NSCollectionView: UserInterface {
  public var visibleViews: [View] {
    var views = [View]()

    for item in visibleItems() {
      guard visibleRect.intersects(item.view.frame) else {
        continue
      }

      switch item {
        case let wrapper as Wrappable:
          guard let view = wrapper.wrappedView else {
            continue
          }
          views.append(view)
        default:
          views.append(item.view)
      }
    }

    return views
  }

  public static var compositeIdentifier: String {
    return "collection-composite"
  }

  public func register() {
    register(GridWrapper.self, forItemWithIdentifier: CollectionView.compositeIdentifier)

    for (identifier, item) in Configuration.views.storage {
      switch item {
      case .classType(_):
        register(GridWrapper.self,
                 forItemWithIdentifier: identifier)
        register(GridWrapper.self,
                 forItemWithIdentifier: Configuration.views.defaultIdentifier)
      case .nib(let nib):
        register(nib, forItemWithIdentifier: identifier)
      }
    }
  }

  public func view<T>(at index: Int) -> T? {
    let view = item(at: index)

    switch view {
    case let view as GridWrapper:
      return view.wrappedView as? T
    default:
      return view as? T
    }
  }

  /**
   A convenience method for performing inserts on a UICollectionView
   - parameter indexes: A collection integers
   - parameter section: The section you want to update
   - parameter completion: A completion block for when the updates are done
   **/
  public func insert(_ indexes: [Int], withAnimation animation: Animation = .automatic, completion: (() -> Void)? = nil) {
    guard let dataSource = dataSource else {
      assertionFailure("Data source could not be resolved.")
      return
    }

    applyAnimation(animation: animation)

    let numberOfRows = dataSource.collectionView(self, numberOfItemsInSection: 0) - indexes.count
    let algorithm = MoveAlgorithm()
    let movedItems = algorithm.calculateMoveForInsertedIndexes(indexes, numberOfItems: numberOfRows)
    let indexPaths = indexes.map { IndexPath(item: $0, section: 0) }
    let set = Set<IndexPath>(indexPaths)
    let instance = animation != .none ? animator() : self

    instance.performBatchUpdates({ [weak self] in
      guard let strongSelf = self else {
        return
      }
      strongSelf.insertItems(at: set as Set<IndexPath>)
      for (from, to) in movedItems {

        strongSelf.moveItem(at: IndexPath(item: from, section: 0),
                            to: IndexPath(item: to, section: 0))
      }
    }) { _ in
      completion?()
    }
  }

  /**
   A convenience method for performing updates on a UICollectionView
   - parameter indexes: A collection integers
   - parameter section: The section you want to update
   - parameter completion: A completion block for when the updates are done
   **/
  public func reload(_ indexes: [Int], withAnimation animation: Animation = .automatic, completion: (() -> Void)? = nil) {
    applyAnimation(animation: animation)
    let indexPaths = indexes.map { IndexPath(item: $0, section: 0) }
    let set = Set<IndexPath>(indexPaths)
    let instance = animation != .none ? animator() : self
    instance.reloadItems(at: set as Set<IndexPath>)
    completion?()
  }

  /**
   A convenience method for performing deletions on a UICollectionView
   - parameter indexes: A collection integers
   - parameter section: The section you want to update
   - parameter completion: A completion block for when the updates are done
   **/
  public func delete(_ indexes: [Int], withAnimation animation: Animation = .automatic, completion: (() -> Void)? = nil) {
    guard let dataSource = dataSource else {
      assertionFailure("Data source could not be resolved.")
      return
    }

    applyAnimation(animation: animation)

    let indexPaths = indexes.map { IndexPath(item: $0, section: 0) }
    let numberOfRows = dataSource.collectionView(self, numberOfItemsInSection: 0)
    let algorithm = MoveAlgorithm()
    let movedItems = algorithm.calculateMoveForDeletedIndexes(indexes, numberOfItems: numberOfRows)
    let set = Set<IndexPath>(indexPaths)
    let instance = animation != .none ? animator() : self

    instance.performBatchUpdates({ [weak self] in
      guard let strongSelf = self else {
        return
      }
      strongSelf.deleteItems(at: set as Set<IndexPath>)
      for (from, to) in movedItems {
        strongSelf.moveItem(at: IndexPath(item: from, section: 0),
                            to: IndexPath(item: to, section: 0))
      }
    }) { _ in
      completion?()
    }
  }

  public func process(_ changes: (insertions: [Int], moved: [Int : Int], reloads: [Int], deletions: [Int], childUpdates: [Int]),
                      withAnimation animation: Animation = .automatic,
                      updateDataSource: () -> Void,
                      completion: ((()) -> Void)? = nil) {
    let instance = animation != .none ? animator() : self
    let deletionSets = Set<IndexPath>(changes.deletions
      .map { IndexPath(item: $0, section: 0) })
    let insertionsSets = Set<IndexPath>(changes.insertions
      .map { IndexPath(item: $0, section: 0) })
    let reloadSets = Set<IndexPath>(changes.reloads
      .map { IndexPath(item: $0, section: 0) })
    let childUpdates = Set<IndexPath>(changes.childUpdates
      .map { IndexPath(item: $0, section: 0) })

    updateDataSource()

    if insertionsSets.isEmpty &&
      reloadSets.isEmpty &&
      deletionSets.isEmpty &&
      changes.moved.isEmpty &&
      changes.childUpdates.isEmpty {
      completion?()
      return
    }

    applyAnimation(animation: animation)

    instance.performBatchUpdates({ [weak self] in
      self?.deleteItems(at: deletionSets)
      self?.insertItems(at: insertionsSets)
      self?.reloadItems(at: reloadSets)

      for move in changes.moved {
        self?.moveItem(at: IndexPath(item: move.key, section: 0),
                      to: IndexPath(item: move.value, section: 0))
      }

      /// Use reload items for child updates, this might need improvements in the future.
      self?.reloadItems(at: childUpdates)
    }, completionHandler: nil)
    completion?()
    removeAnimation()
  }

  public func reloadDataSource() {
    reloadData()
  }

  /**
   A convenience method for reloading a section
   - parameter index: The section you want to update
   - parameter completion: A completion block for when the updates are done
   **/
  public func reloadSection(_ section: Int, withAnimation animation: Animation, completion: (() -> Void)?) {
    performBatchUpdates({ [weak self] in
      guard let strongSelf = self else {
        return
      }
      strongSelf.reloadSections(IndexSet(integer: section))
    }) { _ in
      completion?()
    }
  }

  public func beginUpdates() {}
  public func endUpdates() {}

  private func applyAnimation(animation: Animation) {
    guard let componentFlowLayout = collectionViewLayout as? ComponentFlowLayout else {
      return
    }

    componentFlowLayout.animation = animation
  }

  private func removeAnimation() {
    guard let componentFlowLayout = collectionViewLayout as? ComponentFlowLayout else {
      return
    }

    componentFlowLayout.animation = nil
  }
}
