import Cocoa

public extension NSCollectionView {

  /**
   A convenience method for performing inserts on a UICollectionView
   - Parameter indexes: A collection integers
   - Parameter section: The section you want to update
   - Parameter completion: A completion block for when the updates are done
   **/
  func insert(indexes: [Int], section: Int = 0, completion: (() -> Void)? = nil) {
    let indexPaths = indexes.map { NSIndexPath(forItem: $0, inSection: section) }
    let set = Set<NSIndexPath>(indexPaths)

    performBatchUpdates({ [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.insertItemsAtIndexPaths(set)
    }) { _ in
      completion?()
    }
  }

  /**
   A convenience method for performing updates on a UICollectionView
   - Parameter indexes: A collection integers
   - Parameter section: The section you want to update
   - Parameter completion: A completion block for when the updates are done
   **/
  func reload(indexes: [Int], section: Int = 0, completion: (() -> Void)? = nil) {
    let indexPaths = indexes.map { NSIndexPath(forItem: $0, inSection: section) }
    let set = Set<NSIndexPath>(indexPaths)

    //UIView.performWithoutAnimation {
      self.reloadItemsAtIndexPaths(set)
      completion?()
    //}
  }

  /**
   A convenience method for performing deletions on a UICollectionView
   - Parameter indexes: A collection integers
   - Parameter section: The section you want to update
   - Parameter completion: A completion block for when the updates are done
   **/
  func delete(indexes: [Int], section: Int = 0, completion: (() -> Void)? = nil) {
    let indexPaths = indexes.map { NSIndexPath(forItem: $0, inSection: section) }
    let set = Set<NSIndexPath>(indexPaths)

    performBatchUpdates({ [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.deleteItemsAtIndexPaths(set)
    }) { _ in
      completion?()
    }
  }

  func process(changes: (insertions: [Int], reloads: [Int], deletions: [Int]),
               withAnimation animation: NSTableViewAnimationOptions = .EffectFade,
                             section: Int = 0,
                             updateDataSource: () -> Void,
                             completion: ((()) -> Void)? = nil) {
    let deletionSets = Set<NSIndexPath>(changes.deletions
      .map { NSIndexPath(forItem: $0, inSection: section) })
    let insertionsSets = Set<NSIndexPath>(changes.insertions
      .map { NSIndexPath(forItem: $0, inSection: section) })
    let reloadSets = Set<NSIndexPath>(changes.reloads
      .map { NSIndexPath(forItem: $0, inSection: section) })

    performBatchUpdates({ [weak self] in
      self?.deleteItemsAtIndexPaths(deletionSets)
      self?.insertItemsAtIndexPaths(insertionsSets)
      self?.reloadItemsAtIndexPaths(reloadSets)
      }) { _ in
        completion?()
    }
  }

  /**
   A convenience method for reloading a section
   - Parameter index: The section you want to update
   - Parameter completion: A completion block for when the updates are done
   **/
  func reloadSection(index: Int = 0, completion: (() -> Void)? = nil) {
    performBatchUpdates({ [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.reloadSections(NSIndexSet(index: index))
    }) { _ in
      completion?()
    }
  }
}
