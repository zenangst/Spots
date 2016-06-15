import UIKit

public extension UICollectionView {

  func insert(indexes: [Int], section: Int = 0, completion: (() -> Void)? = nil) {
    let indexPaths = indexes.map { NSIndexPath(forItem: $0, inSection: section) }

    performBatchUpdates({ [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.insertItemsAtIndexPaths(indexPaths)
      }) { _ in
        completion?()
    }
  }

  func reload(indexes: [Int], section: Int = 0, completion: (() -> Void)? = nil) {
    let indexPaths = indexes.map { NSIndexPath(forItem: $0, inSection: section) }

    UIView.performWithoutAnimation {
      self.reloadItemsAtIndexPaths(indexPaths)
      completion?()
    }
  }

  func delete(indexes: [Int], section: Int = 0, completion: (() -> Void)? = nil) {
    let indexPaths = indexes.map { NSIndexPath(forItem: $0, inSection: section) }
    performBatchUpdates({ [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.deleteItemsAtIndexPaths(indexPaths)
      }) { _ in
        completion?()
    }
  }

  func reloadSection(index: Int = 0, completion: (() -> Void)? = nil) {
    performBatchUpdates({ [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.reloadSections(NSIndexSet(index: index))
      }) { _ in
        completion?()
    }
  }
}
