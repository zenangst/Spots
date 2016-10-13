import Cocoa

public extension NSCollectionView {

  /**
   A convenience method for performing inserts on a UICollectionView
   - parameter indexes: A collection integers
   - parameter section: The section you want to update
   - parameter completion: A completion block for when the updates are done
   **/
  func insert(_ indexes: [Int], section: Int = 0, completion: (() -> Void)? = nil) {
    let indexPaths = indexes.map { IndexPath(item: $0, section: section) }
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
  func reload(_ indexes: [Int], section: Int = 0, completion: (() -> Void)? = nil) {
    let indexPaths = indexes.map { IndexPath(item: $0, section: section) }
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
  func delete(_ indexes: [Int], section: Int = 0, completion: (() -> Void)? = nil) {
    let indexPaths = indexes.map { IndexPath(item: $0, section: section) }
    let set = Set<IndexPath>(indexPaths)

    performBatchUpdates({ [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.deleteItems(at: set as Set<IndexPath>)
    }) { _ in
      completion?()
    }
  }

  func process(_ changes: (insertions: [Int], reloads: [Int], deletions: [Int]),
               withAnimation animation: NSTableViewAnimationOptions = .effectFade,
                             section: Int = 0,
                             updateDataSource: () -> Void,
                             completion: ((()) -> Void)? = nil) {
    let deletionSets = Set<IndexPath>(changes.deletions
      .map { IndexPath(item: $0, section: section) })
    let insertionsSets = Set<IndexPath>(changes.insertions
      .map { IndexPath(item: $0, section: section) })
    let reloadSets = Set<IndexPath>(changes.reloads
      .map { IndexPath(item: $0, section: section) })

    performBatchUpdates({ [weak self] in
      self?.deleteItems(at: deletionSets as Set<IndexPath>)
      self?.insertItems(at: insertionsSets as Set<IndexPath>)
      self?.reloadItems(at: reloadSets as Set<IndexPath>)
      }) { _ in
        completion?()
    }
  }

  /**
   A convenience method for reloading a section
   - parameter index: The section you want to update
   - parameter completion: A completion block for when the updates are done
   **/
  func reloadSection(_ index: Int = 0, completion: (() -> Void)? = nil) {
    performBatchUpdates({ [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.reloadSections(IndexSet(integer: index))
    }) { _ in
      completion?()
    }
  }
}
