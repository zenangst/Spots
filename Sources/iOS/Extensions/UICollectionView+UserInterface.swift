// swiftlint:disable large_tuple
import UIKit

extension UICollectionView: UserInterface {

  public static var compositeIdentifier: String {
    return "collection-composite"
  }

  public func register() {
    Configuration.register(view: GridWrapper.self, identifier: CollectionView.compositeIdentifier)
    register(GridWrapper.self, forCellWithReuseIdentifier: CollectionView.compositeIdentifier)

    if Configuration.views.defaultItem == nil {
      register(GridWrapper.self, forCellWithReuseIdentifier: Configuration.views.defaultIdentifier)
    }

    for (identifier, item) in Configuration.views.storage {
      if identifier.contains(CompositeComponent.identifier) {
        continue
      }

      switch item {
      case .classType(let type):
        if type is UICollectionViewCell.Type {
          register(type, forCellWithReuseIdentifier: identifier)
        } else {
          register(GridWrapper.self, forCellWithReuseIdentifier: identifier)
        }

        if type is UICollectionReusableView.Type {
          register(type,
                   forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                   withReuseIdentifier: identifier)
          register(type,
                   forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                   withReuseIdentifier: identifier)
        } else {
          register(GridHeaderFooterWrapper.self,
                   forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                   withReuseIdentifier: identifier)
          register(GridHeaderFooterWrapper.self,
                   forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                   withReuseIdentifier: identifier)
        }
      case .nib(let nib):
        register(nib, forCellWithReuseIdentifier: identifier)
      }
    }
  }

  public var visibleViews: [View] {
    let views = visibleCells.map { view in
      resolveVisibleView(view)
    }

    return views
  }

  /// The index of the current selected item
  @available(iOS 9.0, *)
  public var selectedIndex: Int {
    return indexPathsForSelectedItems?.first?.item ?? 0
  }

  @available(iOS 9.0, *)
  /// The index of the current focused item
  public var focusedIndex: Int {
    return delegate?.indexPathForPreferredFocusedView?(in: self)?.item ?? 0
  }

  /// Focus on item at index
  ///
  /// - parameter index: The index of the item you want to focus.
  @available(iOS 9.0, *)
  public func focusOn(itemAt index: Int) {
    guard index < numberOfItems(inSection: 0) else {
      return
    }

    select(itemAt: index, animated: false)
    setNeedsFocusUpdate()
    deselect(itemAt: index, animated: false)
  }

  /// Select item at index
  ///
  /// - parameter index: The index of the item you want to select.
  /// - parameter animated: Performs an animation if set to true
  public func select(itemAt index: Int, animated: Bool) {
    guard index < numberOfItems(inSection: 0) else {
      return
    }

    selectItem(at: IndexPath(row: index, section: 0), animated: animated, scrollPosition: [])
  }

  /// Deselect item at index
  ///
  /// - parameter index: The index of the item you want to deselect.
  /// - parameter animated: Performs an animation if set to true
  public func deselect(itemAt index: Int, animated: Bool) {
    guard index < numberOfItems(inSection: 0) else {
      return
    }

    deselectItem(at: IndexPath(row: index, section: 0), animated: animated)
  }

  /// Resolve a view at index
  ///
  /// - Parameter index: The item index that should be used to resolve the view.
  /// - Returns: The view that is resolved at the index casted into the inferred type.
  public func view<T>(at index: Int) -> T? {
    let view = cellForItem(at: IndexPath(item: index, section: 0))

    switch view {
    case let view as GridWrapper:
      return view.wrappedView as? T
    default:
      return view as? T
    }
  }

  public func reloadDataSource() {
    reloadData()
    updateContentSize()
  }

  /// A convenience method for performing inserts on a UICollectionView
  ///
  ///  - parameter indexes: A collection integers
  ///  - parameter section: The section you want to update
  ///  - parameter completion: A completion block for when the updates are done
  public func insert(_ indexes: [Int], withAnimation animation: Animation = .automatic, completion: (() -> Void)? = nil) {
    applyAnimation(animation: animation)
    let indexPaths: [IndexPath] = indexes.map {
      IndexPath(item: $0, section: 0)
    }
    let algorithm = MoveAlgorithm()
    let movedItems = algorithm.calculateMoveForInsertedIndexes(indexes, numberOfItems: numberOfItems(inSection: 0))

    performBatchUpdates({
      self.insertItems(at: indexPaths)

      for (from, to) in movedItems {
        self.moveItem(at: IndexPath(item: from, section: 0),
                      to: IndexPath(item: to, section: 0))
      }

    }, completion: nil)
    updateContentSize()
    removeAnimation()
    completion?()
  }

  /// A convenience method for performing updates on a UICollectionView

  ///  - parameter indexes: A collection integers
  ///  - parameter section: The section you want to update
  ///  - parameter completion: A completion block for when the updates are done
  public func reload(_ indexes: [Int], withAnimation animation: Animation = .automatic, completion: (() -> Void)? = nil) {
    applyAnimation(animation: animation)
    let indexPaths = indexes.map { IndexPath(item: $0, section: 0) }

    switch animation {
      case .none:
        UIView.performWithoutAnimation {
          reloadItems(at: indexPaths)
          removeAnimation()
          completion?()
      }
    default:
      reloadItems(at: indexPaths)
      collectionViewLayout.finalizeCollectionViewUpdates()
      updateContentSize()
      removeAnimation()
      completion?()
    }
  }

  /// A convenience method for performing deletions on a UICollectionView
  ///
  ///  - parameter indexes: A collection integers
  ///  - parameter section: The section you want to update
  ///  - parameter completion: A completion block for when the updates are done
  public func delete(_ indexes: [Int], withAnimation animation: Animation = .automatic, completion: (() -> Void)? = nil) {
    applyAnimation(animation: animation)
    let indexPaths = indexes.map { IndexPath(item: $0, section: 0) }
    let algorithm = MoveAlgorithm()
    let movedItems = algorithm.calculateMoveForDeletedIndexes(indexes, numberOfItems: numberOfItems(inSection: 0))

    performBatchUpdates({ [weak self] in
      guard let strongSelf = self else {
        return
      }
      for (from, to) in movedItems {
        strongSelf.moveItem(at: IndexPath(item: from, section: 0),
                            to: IndexPath(item: to, section: 0))
      }
      strongSelf.deleteItems(at: indexPaths)

      }) { _ in }

    updateContentSize()
    removeAnimation()
    completion?()
  }

  /// Process a collection of changes
  ///
  /// - parameter changes:          A tuple with insertions, reloads and delctions
  /// - parameter animation:        The animation that should be used to perform the updates
  /// - parameter section:          The section that will be updates
  ///  - parameter updateDataSource: A closure that is used to update the data source before performing the updates on the UI
  ///  - parameter completion:       A completion closure that will run when both data source and UI is updated
  public func processChanges(_ changes: Changes,
                             withAnimation animation: Animation = .automatic,
                             updateDataSource: () -> Void,
                             completion: ((()) -> Void)? = nil) {
    let insertions = changes.insertions.map { IndexPath(row: $0, section: 0) }
    let reloads = changes.reloads.map { IndexPath(row: $0, section: 0) }
    let deletions = changes.deletions.map { IndexPath(row: $0, section: 0) }

    updateDataSource()

    if insertions.isEmpty &&
      reloads.isEmpty &&
      deletions.isEmpty &&
      changes.moved.isEmpty &&
      changes.childUpdates.isEmpty {
      completion?()
      return
    }

    applyAnimation(animation: animation)

    if animation == .none {
      UIView.performWithoutAnimation {
        performBatchUpdates({
          self.insertItems(at: insertions)
          self.reloadItems(at: reloads)
          self.deleteItems(at: deletions)
          for move in changes.moved {
            self.moveItem(at: IndexPath(item: move.key, section: 0),
                          to: IndexPath(item: move.value, section: 0))
          }
        }) { _ in }
      }
    } else {
      performBatchUpdates({
        self.insertItems(at: insertions)
        self.reloadItems(at: reloads)
        self.deleteItems(at: deletions)
        for move in changes.moved {
          self.moveItem(at: IndexPath(item: move.key, section: 0),
                        to: IndexPath(item: move.value, section: 0))
        }
      }) { _ in }
    }

    updateContentSize()
    removeAnimation()
    completion?()
  }

  func updateContentSize() {
    guard let collectionViewContentSize = (collectionViewLayout as? UICollectionViewFlowLayout)?.collectionViewContentSize else {
      return
    }

    self.contentSize = collectionViewContentSize
  }

  ///  A convenience method for reloading a section
  ///  - parameter index: The section you want to update
  ///  - parameter completion: A completion block for when the updates are done
  public func reloadSection(_ section: Int = 0, withAnimation animation: Animation = .automatic, completion: (() -> Void)? = nil) {
    UIView.performWithoutAnimation {
      performBatchUpdates({ [weak self] in
        guard let strongSelf = self else {
          return
        }
        strongSelf.reloadSections(IndexSet(integer: section))
      }) { _ in
        completion?()
      }
    }
  }

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

  /// Perform batch updates on the data source.
  ///
  /// - Parameters:
  ///   - updateClosure: An update closure that contains everything that should be updated just before `performBatchUpdates` is called.
  ///   - completion: An optional completion closure that is invoked inside the completion handler.
  public func performUpdates( _ updateClosure: () -> Void, completion: (() -> Void)?) {
    updateClosure()
    performBatchUpdates({}) { _ in
      completion?()
    }
  }
}
