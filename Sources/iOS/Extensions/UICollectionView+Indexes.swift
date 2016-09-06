import UIKit

public extension UICollectionView {

  /**
   A convenience method for performing inserts on a UICollectionView
   - Parameter indexes: A collection integers
   - Parameter section: The section you want to update
   - Parameter completion: A completion block for when the updates are done
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
   - Parameter indexes: A collection integers
   - Parameter section: The section you want to update
   - Parameter completion: A completion block for when the updates are done
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
   - Parameter indexes: A collection integers
   - Parameter section: The section you want to update
   - Parameter completion: A completion block for when the updates are done
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
