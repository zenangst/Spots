import UIKit

public extension UICollectionView {

  /**
   A convenience method for performing inserts on a UICollectionView
   - parameter indexes: A collection integers
   - parameter section: The section you want to update
   - parameter completion: A completion block for when the updates are done
  **/
  func insert(indexes: [Int], section: Int = 0, completion: (() -> Void)? = nil) {
    let indexPaths = indexes.map { NSIndexPath(forItem: $0, inSection: section) }

    performBatchUpdates({ [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.insertItemsAtIndexPaths(indexPaths)
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
  func reload(indexes: [Int], section: Int = 0, completion: (() -> Void)? = nil) {
    let indexPaths = indexes.map { NSIndexPath(forItem: $0, inSection: section) }

    UIView.performWithoutAnimation {
      self.reloadItemsAtIndexPaths(indexPaths)
      completion?()
    }
  }

  /**
   A convenience method for performing deletions on a UICollectionView
   - parameter indexes: A collection integers
   - parameter section: The section you want to update
   - parameter completion: A completion block for when the updates are done
   **/
  func delete(indexes: [Int], section: Int = 0, completion: (() -> Void)? = nil) {
    let indexPaths = indexes.map { NSIndexPath(forItem: $0, inSection: section) }
    performBatchUpdates({ [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.deleteItemsAtIndexPaths(indexPaths)
      }) { _ in
        completion?()
    }
  }

  /**
   Process a collection of changes

   - parameter changes:          A tuple with insertions, reloads and delctions
   - parameter animation:        The animation that should be used to perform the updates
   - parameter section:          The section that will be updates
   - parameter updateDataSource: A closure that is used to update the data source before performing the updates on the UI
   - parameter completion:       A completion closure that will run when both data source and UI is updated
   */
  func process(changes: (insertions: [Int], reloads: [Int], deletions: [Int]),
               withAnimation animation: UITableViewRowAnimation = .Automatic,
                             section: Int = 0,
                             updateDataSource: () -> Void,
                             completion: ((()) -> Void)? = nil) {
    let insertions = changes.insertions.map { NSIndexPath(forRow: $0, inSection: section) }
    let reloads = changes.reloads.map { NSIndexPath(forRow: $0, inSection: section) }
    let deletions = changes.deletions.map { NSIndexPath(forRow: $0, inSection: section) }

    updateDataSource()

    if insertions.isEmpty &&
      reloads.isEmpty &&
      deletions.isEmpty {
      completion?()
      return
    }

    performBatchUpdates({
      self.insertItemsAtIndexPaths(insertions)
      self.reloadItemsAtIndexPaths(reloads)
      self.deleteItemsAtIndexPaths(deletions)
      }) { _ in
    }
    completion?()
  }

  /**
   A convenience method for reloading a section
   - parameter index: The section you want to update
   - parameter completion: A completion block for when the updates are done
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
