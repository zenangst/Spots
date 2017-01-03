import UIKit

extension CarouselSpot {
  /// Asks the delegate if the specified item should be selected.
  ///
  /// - parameter collectionView: The collection view object that is asking whether the selection should change.
  /// - parameter indexPath: The index path of the cell to be selected.
  ///
  /// - returns: true if the item should be selected or false if it should not.
  @objc(collectionView:shouldSelectItemAtIndexPath:) public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    if let indexPath = collectionView.indexPathsForSelectedItems?.first {
      collectionView.deselectItem(at: indexPath, animated: true)
      return false
    }
    return true
  }
}
