import UIKit

public class ListAdapter : NSObject {

  var spot: Listable

  init(spot: Listable) {
    self.spot = spot
  }
}

extension ListAdapter: UITableViewDelegate {

  public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return spot.component.meta("headerHeight", 0.0)
  }

  public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return spot.component.title
  }

  public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    spot.spotsDelegate?.spotDidSelectItem(spot, item: spot.item(indexPath))
  }

  public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let reuseIdentifer = spot.component.kind.isPresent ? spot.component.kind : spot.dynamicType.defaultKind

    if let listSpot = spot as? ListSpot, cachedHeader = listSpot.cachedHeaders[reuseIdentifer] {
      cachedHeader.configure(spot.component)
      return cachedHeader as? UIView
    } else if let header = ListSpot.headers[reuseIdentifer] {
      let header = header.init(frame: CGRect(x: 0, y: 0,
        width: tableView.bounds.width,
        height: spot.component.meta("headerHeight", 0.0)))
      return header
    }

    return nil
  }

  public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    spot.component.size = CGSize(
      width: tableView.width,
      height: tableView.height)

    return indexPath.item < spot.component.items.count ? spot.item(indexPath).size.height : 0.0
  }
}

// MARK: - UITableViewDataSource

extension ListAdapter: UITableViewDataSource {

  public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return spot.component.items.count
  }

  public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.item < spot.component.items.count {
      spot.component.items[indexPath.item].index = indexPath.row
    }

    let reuseIdentifier = indexPath.item < spot.component.items.count && spot.item(indexPath).kind.isPresent
      ? spot.item(indexPath).kind : spot.component.kind
    let cell: UITableViewCell = tableView
      .dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
      .then { $0.optimize() }

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
