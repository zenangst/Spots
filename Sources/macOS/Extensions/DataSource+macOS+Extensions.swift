import Cocoa

extension DataSource: NSCollectionViewDataSource {

  /// Asks your data source object to provide the total number of sections.
  ///
  /// - parameter collectionView: The collection view requesting the information.
  @nonobjc public func numberOfSectionsInCollectionView(_ collectionView: NSCollectionView) -> Int {
    return 1
  }

  /// Asks your data source object to provide the number of items in the specified section.
  ///
  /// - parameter collectionView: The collection view requesting the information.
  /// - parameter numberOfItemsInSection: The index number of the section. Section indexes are zero based.
  public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
    guard let spot = spot else {
      return 0
    }

    return spot.component.items.count
  }

  /// Asks your data source object to provide the item at the specified location in the collection view.
  ///
  /// - parameter collectionView: The collection view requesting the information
  /// - parameter indexPath: The index path that specifies the location of the item. This index path contains both the section index and the item index within that section.
  ///
  /// - returns: A configured item object. You must not return nil from this method.
  public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
    let reuseIdentifier: String

    guard let spot = spot else {
      return NSCollectionViewItem()
    }

    /// This is to make sure that all views are registered on the collection view
    spot.register()

    if let gridable = spot as? Gridable {
      reuseIdentifier = gridable.identifier(at: indexPath.item)
    } else {
      reuseIdentifier = spot.identifier(at: indexPath.item)
    }

    let item = collectionView.makeItem(withIdentifier: reuseIdentifier, for: indexPath)

    switch item {
    case let item as GridWrapper:
      if let (_, resolvedView) = Configuration.views.make(reuseIdentifier), let view = resolvedView {
        item.configure(with: view)
        (view as? ContentConfigurable)?.configure(&spot.component.items[indexPath.item])
      }
    case let item as Composable:
      let spots = spot.compositeSpots.filter { $0.itemIndex == indexPath.item }
      item.contentView.frame.size.width = collectionView.frame.size.width
      item.contentView.frame.size.height = spot.computedHeight
      item.configure(&spot.component.items[indexPath.item], compositeSpots: spots)
    case let item as ContentConfigurable:
      item.configure(&spot.component.items[indexPath.item])
    default:
      break
    }

    return item
  }
}

extension DataSource: NSTableViewDataSource {

  /// Returns the number of records managed for aTableView by the data source object.
  ///
  /// - parameter tableView: The table view that sent the message.
  public func numberOfRows(in tableView: NSTableView) -> Int {
    guard let spot = spot else {
      return 0
    }

    return spot.component.items.count
  }

  /// Called by aTableView when the mouse button is released over a table view that previously decided to allow a drop.
  ///
  /// - parameter tableView: The table view that sent the message.
  /// - parameter info: An object that contains more information about this dragging operation.
  /// - parameter row: The index of the proposed target row.
  /// - parameter operation: The type of dragging operation.
  ///
  /// - returns: true if the drop operation was successful, otherwise false.
  public func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
    return false
  }
}
