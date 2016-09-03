import Cocoa

extension CollectionAdapter: NSCollectionViewDelegateFlowLayout {

  public func collectionView(collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> NSSize {
    return spot.sizeForItemAt(indexPath)
  }
}
