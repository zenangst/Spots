import Cocoa

extension CollectionAdapter : NSCollectionViewDelegate {

  public func collectionView(collectionView: NSCollectionView, didSelectItemsAtIndexPaths indexPaths: Set<NSIndexPath>) {
    /*
     This delay is here to avoid an assertion that happens inside the collection view binding,
     it tries to resolve the item at index but it no longer exists so the assertion is thrown.
     This can probably be fixed in a more convenient way in the future without delays.
     */
    Dispatch.delay(for: 0.1) { [spot = spot] in
      guard let first = indexPaths.first,
        item = spot.item(first.item) where first.item < spot.items.count else { return }
      spot.spotsDelegate?.spotDidSelectItem(spot, item: item)
    }
  }
}
