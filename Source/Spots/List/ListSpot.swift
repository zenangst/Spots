import UIKit
import Sugar

typealias TitleSpot = ListSpot

public class ListSpot: NSObject, Spotable, Listable {

  public static var cells = [String : UIView.Type]()
  public static var configure: ((view: UITableView) -> Void)?
  public static var defaultCell: UIView.Type = ListSpotCell.self
  public static var headers = [String : UIView.Type]()

  public let itemHeight: CGFloat = 44

  public var cachedCells = [String : Itemble]()
  public var component: Component
  public var headerHeight: CGFloat = 44
  public var index = 0

  public weak var sizeDelegate: SpotSizeDelegate?
  public weak var spotDelegate: SpotsDelegate?

  private var cachedHeaders = [String : Componentable]()

  public lazy var tableView: UITableView = { [unowned self] in
    let tableView = UITableView()
    tableView.autoresizesSubviews = true
    tableView.autoresizingMask = [
      .FlexibleLeftMargin,
      .FlexibleRightMargin,
      .FlexibleWidth
    ]
    tableView.dataSource = self
    tableView.delegate = self
    tableView.frame.size.width = UIScreen.mainScreen().bounds.width
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.scrollEnabled = false

    return tableView
    }()

  public required init(component: Component) {
    self.component = component
    super.init()

    prepareSpot(self)

    if let headerType = ListSpot.headers[component.kind] {
      let header = headerType.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: headerHeight))
      if let configurable = header as? Componentable {
        configurable.configure(component)
        cachedHeaders[component.kind] = configurable
        headerHeight = configurable.height
      }
    }

    cachedCells.removeAll()
  }

  public convenience init(title: String, kind: String = "list") {
    self.init(component: Component(title: title, kind: kind))
  }

  public func setup() {
    if component.size == nil {
      var height = component.items.reduce(0, combine: { $0 + $1.size.height })

      if !component.title.isEmpty { height += headerHeight }

      tableView.frame.size.width = UIScreen.mainScreen().bounds.width
      tableView.frame.size.height = height
      component.size = CGSize(
        width: tableView.frame.width,
        height: tableView.frame.height)
      sizeDelegate?.sizeDidUpdate()
    }

    ListSpot.configure?(view: tableView)
  }
}

extension ListSpot: UITableViewDelegate {

  public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    spotDelegate?.spotDidSelectItem(self, item: item(indexPath))
  }

  public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    var height = component.items.reduce(0, combine: { $0 + $1.size.height })
    if !component.title.isEmpty { height += headerHeight }
    tableView.frame.size.height = height
    component.size = CGSize(
      width: tableView.frame.width,
      height: tableView.frame.height)
    sizeDelegate?.sizeDidUpdate()

    return item(indexPath).size.height
  }
}

extension ListSpot: UITableViewDataSource {

  public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return !component.title.isEmpty ? headerHeight : 0
  }

  public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return component.title
  }

  public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return component.items.count
  }

  public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if let cachedHeader = cachedHeaders[component.kind] {
      cachedHeader.configure(component)
      return cachedHeader as? UIView
    } else if let header = ListSpot.headers[component.kind] {
      let header = header.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: headerHeight))
      return header
    }

    return nil
  }

  public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell: UITableViewCell
    if let tableViewCell = cachedCells[item(indexPath).kind] as? UITableViewCell {
      cell = tableViewCell
    } else {
      cell = tableView.dequeueReusableCellWithIdentifier(item(indexPath).kind, forIndexPath: indexPath)
    }

    cell.optimize()

    if let itemable = cell as? Itemble {
      itemable.configure(&component.items[indexPath.item])
    }

    return cell
  }
}
