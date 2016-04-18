import UIKit
import Brick

public class ListAdapter : NSObject {

  var spot: Listable
  var collapsedSections = [Int]()

  var sectioned: Bool {
    return spot.component.sectioned
  }

  var headerView: UIView? {
    let reuseIdentifer = spot.component.kind.isPresent ? spot.component.kind : spot.dynamicType.defaultKind
    var headerView: UIView?

    if let cachedHeader = spot.cachedHeaders[reuseIdentifer] {
      cachedHeader.configure(spot.component)
      headerView = cachedHeader as? UIView
    } else if let header = spot.dynamicType.headers[reuseIdentifer] {
      let header = header.init(frame: CGRect(x: 0, y: 0,
        width: spot.tableView.bounds.width,
        height: spot.component.meta("headerHeight", 0.0)))
      headerView = header
    }

    return headerView
  }

  init(spot: Listable) {
    self.spot = spot
    super.init()

    spot.tableView.tableHeaderView = headerView
  }

  func itemsAt(section: Int) -> [ViewModel] {
    let sections = spot.component.items

    guard sectioned else {
      return sections
    }

    return sections[section].relations["items"] ?? []
  }

  func updateItem(section: Int, index: Int, closure: (ViewModel) -> ViewModel) {
    guard sectioned else {
      spot.component.items[index] = closure(spot.component.items[index])
      return
    }

    if let item = spot.component.items[section].relations["items"]?[index] {
      spot.component.items[section].relations["items"]?[index] = closure(item)
    }
  }
}

extension ListAdapter: UITableViewDelegate {

  public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return spot.component.meta("sectionHeaderHeight", 0.0)
  }

  public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    spot.spotsDelegate?.spotDidSelectItem(spot, item: spot.item(indexPath))
  }

  public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard sectioned else { return nil }

    let reuseIdentifier = section < spot.component.items.count
      ? spot.component.items[section].kind : spot.component.kind

    if let header = spot.dynamicType.sections[reuseIdentifier] {
      let header = header.init(frame: CGRect(x: 0, y: 0,
        width: tableView.bounds.width,
        height: spot.component.meta("sectionHeaderHeight", 0.0)))
      let collapsed = collapsedSections.indexOf(section) != nil

      spot.component.items[section].index = section
      spot.component.items[section].meta["collapsed"] = collapsed

      (header as? SpotConfigurable)?.configure(&spot.component.items[section])

      if let index = collapsedSections.indexOf(section) {
        collapsedSections.removeAtIndex(index)
      }

      if collapsed {
        collapsedSections.append(section)
      }

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

  public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return sectioned ? spot.component.items.count : 1
  }

  public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return collapsedSections.indexOf(section) != nil ? 0 : itemsAt(section).count
  }

  public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.item < itemsAt(indexPath.section).count {
      updateItem(indexPath.section, index: indexPath.row, closure: { viewModel -> ViewModel in
        var item = viewModel
        item.index = indexPath.row

        return item
      })
    }

    let reuseIdentifier = indexPath.item < spot.component.items.count && spot.item(indexPath).kind.isPresent
      ? spot.item(indexPath).kind : spot.component.kind
    let cell: UITableViewCell = tableView
      .dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
      .then { $0.optimize() }

    if let cell = cell as? SpotConfigurable where indexPath.item < itemsAt(indexPath.section).count {
      if sectioned {
        cell.configure(&spot.component.items[indexPath.section].relations["items"]![indexPath.item])
      } else {
        cell.configure(&spot.component.items[indexPath.item])
      }

      if spot.item(indexPath).size.height == 0.0 {
        updateItem(indexPath.section, index: indexPath.row, closure: { viewModel -> ViewModel in
          var item = viewModel
          item.size = cell.size

          return item
        })
      }

      spot.configure?(cell)
    }

    return cell
  }
}
