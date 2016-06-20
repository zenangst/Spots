import UIKit

/**
 The ListAdapter works as a proxy handler for all Listable object
 */
public class ListAdapter: NSObject {
  // An unowned Gridable object
  unowned var spot: Listable

  /**
   Initialization a new instance of a ListAdapter using a Listable object

   - Parameter spot: A Listable object
   */
  init(spot: Listable) {
    self.spot = spot
  }
}

/**
 A UITableViewDelegate extension on ListAdapter
 */
extension ListAdapter: UITableViewDelegate {

  /**
   Asks the delegate for the height to use for the header of a particular section.

   - Parameter tableView	: The table-view object requesting this information.
   - Parameter heightForHeaderInSection: An index number identifying a section of tableView.
   - Returns: Returns the `headerHeight` found in `component.meta`, otherwise 0.0.
   **/
  public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return spot.component.meta("headerHeight", 0.0)
  }

  /**
   Asks the data source for the title of the header of the specified section of the table view.

   - Parameter tableView	: The table-view object asking for the title.
   - Parameter section: An index number identifying a section of tableView.
   - Returns: A string to use as the title of the section header. Will return `nil` if title is not present on Component
   **/
  public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return spot.component.title.isPresent ? spot.component.title : nil
  }

  /**
   Tells the delegate that the specified row is now selected.

   - Parameter tableView	: A table-view object informing the delegate about the new row selection.
   - Parameter indexPath: An index path locating the new selected row in tableView.
   **/
  public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    spot.spotsDelegate?.spotDidSelectItem(spot, item: spot.item(indexPath))
  }

  /**
   Asks the delegate for a view object to display in the header of the specified section of the table view.

   - Parameter tableView	: The table-view object asking for the view object.
   - Parameter section: An index number identifying a section of tableView.
   - Returns: A view object to be displayed in the header of section based on the kind of the ListSpot and registered headers.
   **/
  public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard spot.component.meta("headerHeight", type: CGFloat.self) != 0.0 else { return nil }

    let reuseIdentifer = spot.component.kind.isPresent ? spot.component.kind : spot.dynamicType.defaultKind

    if let listSpot = spot as? ListSpot, cachedHeader = listSpot.cachedHeaders[reuseIdentifer.string] {
      cachedHeader.configure(spot.component)
      return cachedHeader as? UIView
    } else if let header = ListSpot.headers[reuseIdentifer] {
      let header = header.init(frame: CGRect(x: 0, y: 0,
        width: tableView.bounds.width,
        height: spot.component.meta("headerHeight", 0.0)))
      (header as? Componentable)?.configure(spot.component)
      return header
    }

    return nil
  }

  /**
   Asks the delegate for the height to use for a row in a specified location.

   - Parameter tableView: The table-view object requesting this information.
   - Parameter indexPath: An index path that locates a row in tableView.
   - Returns:  A nonnegative floating-point value that specifies the height (in points) that row should be based on the view model height, defaults to 0.0.
   */
  public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    spot.component.size = CGSize(
      width: tableView.width,
      height: tableView.height)

    return indexPath.item < spot.component.items.count ? spot.item(indexPath).size.height : 0.0
  }
}

// MARK: - UITableViewDataSource

extension ListAdapter: UITableViewDataSource {

  /**
   Tells the data source to return the number of rows in a given section of a table view. (required)

   - Parameter tableView	: The table-view object requesting this information.
   - Parameter section: An index number identifying a section in tableView.
   - Returns: The number of rows in section.
   */
  public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return spot.component.items.count
  }

  /**
   Asks the data source for a cell to insert in a particular location of the table view. (required)

   - Parameter tableView	: A table-view object requesting the cell.
indexPath
   - Parameter indexPath: An index path locating a row in tableView.
   - Returns: An object inheriting from UITableViewCell that the table view can use for the specified row. Will return the default table view cell for the current component based of kind.
 */
  public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.item < spot.component.items.count {
      spot.component.items[indexPath.item].index = indexPath.row
    }

    let reuseIdentifier = spot.reuseIdentifierForItem(indexPath)
    let cell: UITableViewCell = tableView
      .dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)

    #if os(iOS)
      cell.optimize()
    #endif

    if let cell = cell as? SpotConfigurable where indexPath.item < spot.component.items.count {
      cell.configure(&spot.component.items[indexPath.item])
      if spot.component.items[indexPath.item].size.height == 0.0 {
        spot.component.items[indexPath.item].size = cell.size
      }

      spot.configure?(cell)
    }

    return cell
  }
}
