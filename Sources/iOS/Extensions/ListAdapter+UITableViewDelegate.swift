import UIKit

/**
 A UITableViewDelegate extension on ListAdapter
 */
extension ListAdapter: UITableViewDelegate {

  /**
   Asks the delegate for the height to use for the header of a particular section.

   - parameter tableView: The table-view object requesting this information.
   - parameter heightForHeaderInSection: An index number identifying a section of tableView.
   - returns: Returns the `headerHeight` found in `component.meta`, otherwise 0.0.
   **/
  public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    let header = spot.dynamicType.headers.make(spot.component.header)
    return (header?.view as? Componentable)?.defaultHeight ?? 0.0
  }

  /**
   Asks the data source for the title of the header of the specified section of the table view.

   - parameter tableView: The table-view object asking for the title.
   - parameter section: An index number identifying a section of tableView.
   - returns: A string to use as the title of the section header. Will return `nil` if title is not present on Component
   **/
  public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if let _ = spot.dynamicType.headers.make(spot.component.header) {
      return nil
    }
    return !spot.component.title.isEmpty ? spot.component.title : nil
  }

  /**
   Tells the delegate that the specified row is now selected.

   - parameter tableView: A table-view object informing the delegate about the new row selection.
   - parameter indexPath: An index path locating the new selected row in tableView.
   **/
  public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    if let item = spot.item(indexPath) {
      spot.spotsDelegate?.spotDidSelectItem(spot, item: item)
    }
  }

  /**
   Asks the delegate for a view object to display in the header of the specified section of the table view.

   - parameter tableView: The table-view object asking for the view object.
   - parameter section: An index number identifying a section of tableView.
   - returns: A view object to be displayed in the header of section based on the kind of the ListSpot and registered headers.
   **/
  public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard !spot.component.header.isEmpty else { return nil }

    let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier(spot.component.header)
    view?.frame.size.height = spot.component.meta(ListSpot.Key.headerHeight, 0.0)
    view?.frame.size.width = spot.tableView.frame.size.width
    (view as? Componentable)?.configure(spot.component)

    return view
  }

  /**
   Asks the delegate for the height to use for a row in a specified location.

   - parameter tableView: The table-view object requesting this information.
   - parameter indexPath: An index path that locates a row in tableView.
   - returns:  A nonnegative floating-point value that specifies the height (in points) that row should be based on the view model height, defaults to 0.0.
   */
  public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    spot.component.size = CGSize(
      width: tableView.frame.size.width,
      height: tableView.frame.size.height)

    return spot.item(indexPath)?.size.height ?? 0
  }
}
