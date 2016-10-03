import Cocoa

extension CollectionAdapter: NSCollectionViewDataSource {

  @nonobjc public func numberOfSectionsInCollectionView(_ collectionView: NSCollectionView) -> Int {
    return 1
  }

  public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
    return spot.component.items.count
  }

  public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
    let reuseIdentifier = spot.identifier(indexPath.item)
    let item = collectionView.makeItem(withIdentifier: reuseIdentifier, for: indexPath as IndexPath)

    (item as? SpotConfigurable)?.configure(&spot.component.items[indexPath.item])
    return item
  }
}
