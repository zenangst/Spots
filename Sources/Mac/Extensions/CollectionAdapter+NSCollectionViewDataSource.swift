import Cocoa

extension CollectionAdapter: NSCollectionViewDataSource {

  public func numberOfSectionsInCollectionView(collectionView: NSCollectionView) -> Int {
    return 1
  }

  public func collectionView(collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
    return spot.component.items.count
  }

  public func collectionView(collectionView: NSCollectionView, itemForRepresentedObjectAtIndexPath indexPath: NSIndexPath) -> NSCollectionViewItem {
    let reuseIdentifier = spot.identifier(indexPath.item)
    let item = collectionView.makeItemWithIdentifier(reuseIdentifier, forIndexPath: indexPath)

    (item as? SpotConfigurable)?.configure(&spot.component.items[indexPath.item])
    return item
  }
}
