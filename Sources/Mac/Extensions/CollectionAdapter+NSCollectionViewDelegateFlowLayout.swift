import Cocoa

extension CollectionAdapter: NSCollectionViewDelegateFlowLayout {

  public func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
    return spot.sizeForItemAt(indexPath as IndexPath)
  }
}
