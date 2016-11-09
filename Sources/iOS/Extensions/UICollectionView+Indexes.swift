import UIKit

public extension UICollectionView {

  /// A convenience method for performing inserts on a UICollectionView
  ///
  ///  - parameter indexes: A collection integers
  ///  - parameter section: The section you want to update
  ///  - parameter completion: A completion block for when the updates are done
  func insert(_ indexes: [Int], section: Int = 0, completion: (() -> Void)? = nil) {
    let indexPaths = indexes.map { IndexPath(item: $0, section: section) }

    performBatchUpdates({ [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.insertItems(at: indexPaths)
      }) { _ in
        completion?()
    }
  }

  /// A convenience method for performing updates on a UICollectionView

  ///  - parameter indexes: A collection integers
  ///  - parameter section: The section you want to update
  ///  - parameter completion: A completion block for when the updates are done
  func reload(_ indexes: [Int], section: Int = 0, completion: (() -> Void)? = nil) {
    let indexPaths = indexes.map { IndexPath(item: $0, section: section) }

    UIView.performWithoutAnimation {
      self.reloadItems(at: indexPaths)
      completion?()
    }
  }

  /// A convenience method for performing deletions on a UICollectionView
  ///
  ///  - parameter indexes: A collection integers
  ///  - parameter section: The section you want to update
  ///  - parameter completion: A completion block for when the updates are done
  func delete(_ indexes: [Int], section: Int = 0, completion: (() -> Void)? = nil) {
    let indexPaths = indexes.map { IndexPath(item: $0, section: section) }
    performBatchUpdates({ [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.deleteItems(at: indexPaths)
      }) { _ in
        completion?()
    }
  }

  /// Process a collection of changes
  ///
  /// - parameter changes:          A tuple with insertions, reloads and delctions
  /// - parameter animation:        The animation that should be used to perform the updates
  /// - parameter section:          The section that will be updates
  ///  - parameter updateDataSource: A closure that is used to update the data source before performing the updates on the UI
  ///  - parameter completion:       A completion closure that will run when both data source and UI is updated
  func process(_ changes: (insertions: [Int], reloads: [Int], deletions: [Int]),
               withAnimation animation: UITableViewRowAnimation = .automatic,
                             section: Int = 0,
                             updateDataSource: () -> Void,
                             completion: ((()) -> Void)? = nil) {
    let insertions = changes.insertions.map { IndexPath(row: $0, section: section) }
    let reloads = changes.reloads.map { IndexPath(row: $0, section: section) }
    let deletions = changes.deletions.map { IndexPath(row: $0, section: section) }

    updateDataSource()

    if insertions.isEmpty &&
      reloads.isEmpty &&
      deletions.isEmpty {
      completion?()
      return
    }

    UIView.performWithoutAnimation {
      performBatchUpdates({
        self.insertItems(at: insertions)
        self.reloadItems(at: reloads)
        self.deleteItems(at: deletions)
      }) { _ in }
    }
    completion?()
  }

  ///  A convenience method for reloading a section
  ///  - parameter index: The section you want to update
  ///  - parameter completion: A completion block for when the updates are done
  func reloadSection(_ index: Int = 0, completion: (() -> Void)? = nil) {
    performBatchUpdates({ [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.reloadSections(IndexSet(integer: index))
      }) { _ in
        completion?()
    }
  }
}
