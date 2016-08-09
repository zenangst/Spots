import UIKit
import Sugar
import Brick

public class ListSpot: NSObject, Listable {

  public static var views = ViewRegistry().then {
    $0.defaultView = ListSpotCell.self
  }

  public static var nibs = NibRegistry()
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

  public var adapter: SpotAdapter? {
    return listAdapter
  }
  public lazy var listAdapter: ListAdapter = ListAdapter(spot: self)
  public lazy var tableView = UITableView()

  private var fetching = false
  public private(set) var stateCache: SpotCache?

  // MARK: - Initializers

  public required init(component: Component) {
    self.component = component
    super.init()

    setupTableView()
    registerAndPrepare()

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
    registerAndPrepare() // FIXME: Why call again?
  }

  public convenience init(cacheKey: String, tableView: UITableView? = nil) {
    let stateCache = SpotCache(key: cacheKey)

    self.init(component: Component(stateCache.load()))
    self.stateCache = stateCache
    self.tableView ?= tableView

    setupTableView()
    registerAndPrepare() // FIXME: Why call again?
  }

  // MARK: - Setup

  public func setup(size: CGSize) {
    registerAndPrepare() // FIXME: Why call again?
    let height = component.items.reduce(component.meta("headerHeight", 0.0),
                                        combine: { $0 + $1.size.height })

    tableView.frame.size = size
    tableView.contentSize = CGSize(
      width: tableView.width,
      height: height - tableView.contentInset.top - tableView.contentInset.bottom)

    ListSpot.configure?(view: tableView)
  }

  func setupTableView() {
    tableView.dataSource = self.listAdapter
    tableView.delegate = self.listAdapter
    tableView.rowHeight = UITableViewAutomaticDimension
  }

  // MARK: - Spotable

  public func register() {
    tableView.registerClass(self.dynamicType.views.defaultView,
                            forCellReuseIdentifier: String(self.dynamicType.views.defaultView))

    self.dynamicType.views.storage.forEach { identifier, type in
      self.tableView.registerClass(type, forCellReuseIdentifier: identifier)
    }

    self.dynamicType.nibs.storage.forEach { identifier, nib in
      self.tableView.registerNib(nib, forCellReuseIdentifier: identifier)
    }

    self.dynamicType.headers.storage.forEach { identifier, type in
      self.tableView.registerClass(type, forHeaderFooterViewReuseIdentifier: identifier)
    }
  }

  public func cachedViewFor(item: ViewModel, inout cache: View?) {
    if let view = tableView.dequeueReusableCellWithIdentifier(item.kind) {
      cache = view
      return
    }
  }

  public func dequeueView(identifier: String, indexPath: NSIndexPath) -> View? {
    return tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
  }

  public func identifier(index: Int) -> String? {
    guard let kind = item(index)?.kind else { return nil }

    if self.dynamicType.views.storage[kind] != nil {
      return kind
    }

    if self.dynamicType.nibs.storage[kind] != nil {
      return kind
    }

    return nil
  }
}
