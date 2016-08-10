import UIKit
import Sugar
import Brick

public class ListSpot: NSObject, Listable {

  public static var views = Registry().then {
    $0.defaultItem = Registry.Item.classType(ListSpotCell.self)
  }

  public static var configure: ((view: UITableView) -> Void)?
  public static var headers = Registry()

  public var index = 0
  public var component: Component
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

    if component.kind.isEmpty {
      self.component.kind = "list"
    }

    setupTableView()
    registerAndPrepare()
  }

  public convenience init(tableView: UITableView? = nil, title: String = "", kind: String? = nil) {
    self.init(component: Component(title: title, kind: kind ?? "list"))

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
    for (identifier, item) in self.dynamicType.views.storage {
      switch item {
      case .classType(let classType):
        self.tableView.registerClass(classType, forCellReuseIdentifier: identifier)
      case .nib(let nib):
        self.tableView.registerNib(nib, forCellReuseIdentifier: identifier)
      }
    }

    for (identifier, item) in self.dynamicType.headers.storage {
      switch item {
      case .classType(let classType):
        self.tableView.registerClass(classType, forHeaderFooterViewReuseIdentifier: identifier)
      case .nib(let nib):
        self.tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: identifier)
      }
    }
  }

  public func identifier(index: Int) -> String? {
    // FIXME:

    return nil
  }
}
