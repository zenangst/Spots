import UIKit
import Sugar
import Brick

public class ListSpot: NSObject, Listable {

  public struct Key {
    public static let headerHeight = "headerHeight"
  }

  public static var views: Registry = Registry()
  public static var configure: ((view: UITableView) -> Void)?
  public static var headers = Registry()

  public var component: Component
  public var configure: (SpotConfigurable -> Void)?

  public weak var spotsCompositeDelegate: SpotsCompositeDelegate?
  public weak var spotsDelegate: SpotsDelegate?

  public var adapter: SpotAdapter? {
    return listAdapter
  }
  public lazy var listAdapter: ListAdapter = ListAdapter(spot: self)
  public lazy var tableView = UITableView()

  private var fetching = false
  public private(set) var stateCache: SpotCache?
  /// Indicator to calculate the height based on content
  public var usesDynamicHeight = true

  // MARK: - Initializers

  public required init(component: Component) {
    self.component = component
    super.init()

    if component.kind.isEmpty {
      self.component.kind = "list"
    }

    registerAndPrepare()
    setupTableView()

    if ListSpot.views.defaultItem == nil {
      ListSpot.views.defaultItem = Registry.Item.classType(ListSpotCell.self)
    }

    if ListSpot.views.composite == nil {
      ListSpot.views.composite =  Registry.Item.classType(ListComposite.self)
    }
  }

  public convenience init(tableView: UITableView? = nil, title: String = "",
                          kind: String = "list", header: String = "") {
    self.init(component: Component(title: title, kind: kind, header: header))

    self.tableView ?= tableView

    setupTableView()
    registerAndPrepare()
  }

  public convenience init(cacheKey: String, tableView: UITableView? = nil) {
    let stateCache = SpotCache(key: cacheKey)

    self.init(component: Component(stateCache.load()))
    self.stateCache = stateCache
    self.tableView ?= tableView

    setupTableView()
    registerAndPrepare()
  }

  // MARK: - Setup

  public func setup(size: CGSize) {
    registerAndPrepare()
    let height = component.items.reduce(component.meta(Key.headerHeight, 0.0),
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

  public static func register(header header: View.Type, identifier: StringConvertible) {
    self.headers.storage[identifier.string] = Registry.Item.classType(header)
  }

  public static func register(defaultHeader header: View.Type) {
    self.headers.storage[self.views.defaultIdentifier] = Registry.Item.classType(header)
  }
}
