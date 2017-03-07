import Cocoa

extension NSCollectionView: UserInterface {

  public func register() {
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
    let indexPaths = indexes.map { IndexPath(item: $0, section: 0) }
    let set = Set<IndexPath>(indexPaths)

    performBatchUpdates({ [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.insertItems(at: set as Set<IndexPath>)
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
    let indexPaths = indexes.map { IndexPath(item: $0, section: 0) }
    let set = Set<IndexPath>(indexPaths)

    //UIView.performWithoutAnimation {
      self.reloadItems(at: set as Set<IndexPath>)
      completion?()
    //}
  }

  /**
   A convenience method for performing deletions on a UICollectionView
   - parameter indexes: A collection integers
   - parameter section: The section you want to update
   - parameter completion: A completion block for when the updates are done
   **/
  public func delete(_ indexes: [Int], withAnimation animation: Animation = .automatic, completion: (() -> Void)? = nil) {
    let indexPaths = indexes.map { IndexPath(item: $0, section: 0) }
    let set = Set<IndexPath>(indexPaths)

    performBatchUpdates({ [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.deleteItems(at: set as Set<IndexPath>)
    }) { _ in
      completion?()
    }
  }

  public func process(_ changes: (insertions: [Int], reloads: [Int], deletions: [Int], childUpdates: [Int]),
                      withAnimation animation: Animation = .automatic,
                      updateDataSource: () -> Void,
                      completion: ((()) -> Void)? = nil) {
    let deletionSets = Set<IndexPath>(changes.deletions
      .map { IndexPath(item: $0, section: 0) })
    let insertionsSets = Set<IndexPath>(changes.insertions
      .map { IndexPath(item: $0, section: 0) })
    let reloadSets = Set<IndexPath>(changes.reloads
      .map { IndexPath(item: $0, section: 0) })
    let childUpdates = Set<IndexPath>(changes.childUpdates
      .map { IndexPath(item: $0, section: 0) })

    performBatchUpdates({ [weak self] in
      self?.deleteItems(at: deletionSets)
      self?.insertItems(at: insertionsSets)
      self?.reloadItems(at: reloadSets)
      /// Use reload items for child updates, this might need improvements in the future.
      self?.reloadItems(at: childUpdates)
    }, completionHandler: nil)

    completion?()
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
      guard let weakSelf = self else { return }
      weakSelf.reloadSections(IndexSet(integer: section))
    }) { _ in
      completion?()
    }
  }

  public func beginUpdates() {}
  public func endUpdates() {}
}
