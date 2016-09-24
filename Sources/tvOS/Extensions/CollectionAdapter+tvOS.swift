import UIKit

extension CollectionAdapter {
  /**
   Asks the delegate if the specified item should be selected.

   - parameter collectionView: The collection view object that is asking whether the selection should change.
   - parameter indexPath: The index path of the cell to be selected.
   - returns: true if the item should be selected or false if it should not.
   */
  public func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    if let indexPath = collectionView.indexPathsForSelectedItems()?.first {
      collectionView.deselectItemAtIndexPath(indexPath, animated: true)
      return false
    }

    return true
  }
}
