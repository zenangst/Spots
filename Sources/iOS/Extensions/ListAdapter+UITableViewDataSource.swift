import UIKit

/// MARK: - UITableViewDataSource
extension ListAdapter: UITableViewDataSource {

  /**
   Tells the data source to return the number of rows in a given section of a table view. (required)

   - parameter tableView: The table-view object requesting this information.
   - parameter section: An index number identifying a section in tableView.

   - returns: The number of rows in section.
   */
  public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return spot.component.items.count
  }

  /**
   Asks the data source for a cell to insert in a particular location of the table view. (required)

   - parameter tableView: A table-view object requesting the cell.
   indexPath
   - parameter indexPath: An index path locating a row in tableView.
   - returns: An object inheriting from UITableViewCell that the table view can use for the specified row. Will return the default table view cell for the current component based of kind.
   */
  public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.item < spot.component.items.count {
      spot.component.items[indexPath.item].index = indexPath.row
    }

    let reuseIdentifier = spot.identifier(indexPath)
    let cell: UITableViewCell = tableView
      .dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)

    guard indexPath.item < spot.component.items.count else { return cell }

    if let composite = cell as? SpotComposable {
      let spots = spot.spotsCompositeDelegate?.resolve(spotIndex: spot.index, itemIndex: indexPath.item)
      composite.configure(&spot.component.items[indexPath.item], spots: spots)
    } else if let cell = cell as? SpotConfigurable {
      cell.configure(&spot.component.items[indexPath.item])

      if spot.component.items[indexPath.item].size.height == 0.0 {
        spot.component.items[indexPath.item].size = cell.preferredViewSize
      }

      spot.configure?(cell)
    }

    return cell
  }
}
