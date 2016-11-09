import Cocoa

extension DataSource: NSCollectionViewDataSource {

  @nonobjc public func numberOfSectionsInCollectionView(_ collectionView: NSCollectionView) -> Int {
    return 1
  }

  public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
    guard let spot = spot else {
      return 0
    }

    return spot.component.items.count
  }

  public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
    guard let spot = spot else {
      return NSCollectionViewItem()
    }

    let reuseIdentifier: String

    if let gridable = spot as? Gridable {
      reuseIdentifier = gridable.identifier(at: indexPath.item)
    } else {
      reuseIdentifier = spot.identifier(at: indexPath.item)
    }

    let item = collectionView.makeItem(withIdentifier: reuseIdentifier, for: indexPath)

    (item as? SpotConfigurable)?.configure(&spot.component.items[indexPath.item])
    return item
  }
}

extension DataSource: NSTableViewDataSource {

  public func numberOfRows(in tableView: NSTableView) -> Int {
    guard let spot = spot else {
      return 0
    }

    return spot.component.items.count
  }

  public func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
    return false
  }
}
