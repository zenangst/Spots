import UIKit
import Sugar

public class ListSpot: NSObject, Spotable, Listable {

  public static var views = [String : UIView.Type]()
  public static var configure: ((view: UITableView) -> Void)?
  public static var defaultView: UIView.Type = ListSpotCell.self
  public static var headers = [String : UIView.Type]()

  public var index = 0
  public var headerHeight: CGFloat = 44
  public var component: Component
  public var cachedHeaders = [String : Componentable]()
  public var cachedCells = [String : ViewConfigurable]()

  public let itemHeight: CGFloat = 44

  public weak var spotsDelegate: SpotsDelegate?

  private var fetching = false

  public lazy var tableView: UITableView = UITableView().then { [unowned self] in
    $0.dataSource = self
    $0.delegate = self
    $0.rowHeight = UITableViewAutomaticDimension
  }

  public required init(component: Component) {
    self.component = component
    super.init()
    prepare()

    let reuseIdentifer = component.kind.isEmpty ? "list" : component.kind
    if let headerType = ListSpot.headers[reuseIdentifer] {
      let header = headerType.init(frame: CGRect(x: 0, y: 0,
        width: UIScreen.mainScreen().bounds.width, height: headerHeight))

      if let configurable = header as? Componentable {
        configurable.configure(component)
        cachedHeaders[reuseIdentifer] = configurable
        headerHeight = configurable.height
      }
    }
  }

  public convenience init(title: String = "", kind: String = "list") {
    self.init(component: Component(title: title, kind: kind))
  }

  public func setup(size: CGSize) {
    prepare()
    var height = component.items.reduce(0, combine: { $0 + $1.size.height })

    if !component.title.isEmpty { height += headerHeight }

    tableView.frame.size = size
    tableView.contentSize = CGSize(
      width: tableView.frame.width,
      height: height - tableView.contentInset.top - tableView.contentInset.bottom)

    ListSpot.configure?(view: tableView)
  }
}

extension ListSpot: UITableViewDelegate {

  public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return !component.title.isEmpty ? headerHeight : 0
  }

  public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return component.title
  }

  public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    spotsDelegate?.spotDidSelectItem(self, item: item(indexPath))
  }

  public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let reuseIdentifer = component.kind.isEmpty ? "list" : component.kind
    if let cachedHeader = cachedHeaders[reuseIdentifer] {
      cachedHeader.configure(component)
      return cachedHeader as? UIView
    } else if let header = ListSpot.headers[reuseIdentifer] {
      let header = header.init(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: headerHeight))
      return header
    }

    return nil
  }

  public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    component.size = CGSize(
      width: tableView.frame.width,
      height: tableView.frame.height)

    return indexPath.item < component.items.count ? item(indexPath).size.height : 0.0
  }
}

extension ListSpot: UITableViewDataSource {

  public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return component.items.count
  }

  public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.item < component.items.count {
      component.items[indexPath.item].index = indexPath.row
    }

    let reuseIdentifier = indexPath.item < component.items.count && !item(indexPath).kind.isEmpty
      ? item(indexPath).kind : component.kind
    let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath).then { $0.optimize() }

    if indexPath.item < component.items.count {
      (cell as? ViewConfigurable)?.configure(&component.items[indexPath.item])
    }

    return cell
  }
}
