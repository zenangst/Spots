import UIKit
import Sugar
import Brick

public class ListSpot: NSObject, Listable {

  public static var views = ViewRegistry()
  public static var configure: ((view: UITableView) -> Void)?
  public static var defaultView: UIView.Type = ListSpotCell.self
  public static var defaultKind: StringConvertible = "list"
  public static var headers = ViewRegistry()

  public var index = 0
  public var component: Component
  public var cachedHeaders = [String : Componentable]()
  public var cachedCells = [String : SpotConfigurable]()
  public var configure: (SpotConfigurable -> Void)?

  public weak var spotsDelegate: SpotsDelegate?

  public lazy var adapter: ListAdapter = ListAdapter(spot: self)
  public lazy var tableView = UITableView()

  private var fetching = false
  public private(set) var stateCache: SpotCache?

  // MARK: - Initializers

  public required init(component: Component) {
    self.component = component
    super.init()

    setupTableView()
    prepare()

    let reuseIdentifer = component.kind.isPresent ? component.kind : self.dynamicType.defaultKind

    guard let headerType = ListSpot.headers[reuseIdentifer]  else { return }

    let header = headerType.init(frame: CGRect(x: 0, y: 0,
      width: UIScreen.mainScreen().bounds.width, height: component.meta("headerHeight", 0.0)))

    if let configurable = header as? Componentable {
      configurable.configure(component)
      cachedHeaders[reuseIdentifer.string] = configurable
    }
  }

  public convenience init(tableView: UITableView? = nil, title: String = "", kind: String? = nil) {
    self.init(component: Component(title: title, kind: kind ?? ListSpot.defaultKind.string))

    self.tableView ?= tableView

    setupTableView()
    prepare()
  }

  public convenience init(cacheKey: String, tableView: UITableView? = nil) {
    let stateCache = SpotCache(key: cacheKey)
    
    self.init(component: Component(stateCache.load()))
    self.stateCache = stateCache
    self.tableView ?= tableView

    setupTableView()
    prepare()
  }

  // MARK: - Setup

  public func setup(size: CGSize) {
    prepare()
    let height = component.items.reduce(component.meta("headerHeight", 0.0),
                                        combine: { $0 + $1.size.height })

    tableView.frame.size = size
    tableView.contentSize = CGSize(
      width: tableView.width,
      height: height - tableView.contentInset.top - tableView.contentInset.bottom)

    ListSpot.configure?(view: tableView)
  }

  func setupTableView() {
    tableView.dataSource = self.adapter
    tableView.delegate = self.adapter
    tableView.rowHeight = UITableViewAutomaticDimension
  }
}
