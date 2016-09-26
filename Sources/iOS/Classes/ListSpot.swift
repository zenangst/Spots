import UIKit
import Brick

public class ListSpot: NSObject, Listable {

  /**
   *  Keys for meta data lookup
   */
  public struct Key {
    public static let headerHeight = "headerHeight"
    public static let separator = "separator"
  }

  /// A Registry object that holds identifiers and classes for cells used in the ListSpot
  public static var views: Registry = Registry()

  /// A configuration closure that is run in setup(_:)
  public static var configure: ((view: UITableView) -> Void)?

  /// A Registry object that holds identifiers and classes for headers used in the ListSpot
  public static var headers = Registry()

  /// A component struct used as configuration and data source for the ListSpot
  public var component: Component

  /// A configuration closure
  public var configure: (SpotConfigurable -> Void)?

  /// A SpotsCompositeDelegate for the GridSpot, used to access composite spots
  public weak var spotsCompositeDelegate: SpotsCompositeDelegate?

  /// A SpotsDelegate that is used for the GridSpot
  public weak var spotsDelegate: SpotsDelegate?

  /// A computed variable for adapters
  public var adapter: SpotAdapter? {
    return listAdapter
  }

  /// A list adapter that is the data source and delegate for the ListSpot
  public lazy var listAdapter: ListAdapter = ListAdapter(spot: self)

  /// A UITableView, used as the main UI component for a ListSpot
  public lazy var tableView = UITableView()

  /// A SpotCache for the ListSpot
  public private(set) var stateCache: SpotCache?

  /// Indicator to calculate the height based on content
  public var usesDynamicHeight = true

  // MARK: - Initializers

  /**
   A required initializer to instantiate a ListSpot with a component

   - parameter component: A component
   */
  public required init(component: Component) {
    self.component = component
    super.init()

    if component.kind.isEmpty {
      self.component.kind = "list"
    }

    registerDefault(view: ListSpotCell.self)
    registerComposite(view: ListComposite.self)
    registerAndPrepare()
    setupTableView()
  }

  /**
   A convenience init for initializing a ListSpot with a custom tableview, title and a kind

   - parameter tableView: A UITableView
   - parameter title:     A string that is used as a title for the ListSpot
   - parameter kind:      An identifier to determine which kind should be set on the Component
   - parameter header:    An identifier to determine which header should be used
   */
  public convenience init(tableView: UITableView? = nil, title: String = "",
                          kind: String = "list", header: String = "") {
    self.init(component: Component(title: title, kind: kind, header: header))

    if let tableView = tableView {
      self.tableView = tableView
    }

    setupTableView()
    registerAndPrepare()
  }

  /**
   Instantiate a ListSpot with a cache key

   - parameter cacheKey: A unique cache key for the Spotable object
   - parameter tableView: A UITableView
   */
  public convenience init(cacheKey: String, tableView: UITableView? = nil) {
    let stateCache = SpotCache(key: cacheKey)

    self.init(component: Component(stateCache.load()))
    self.stateCache = stateCache

    if let tableView = tableView {
      self.tableView = tableView
    }

    setupTableView()
    registerAndPrepare()
  }

  // MARK: - Setup

  /**
   Setup Spotable component with base size

   - parameter size: The size of the superview
   */
  public func setup(size: CGSize) {
    registerAndPrepare()
    let height = component.items.reduce(component.meta(Key.headerHeight, 0.0),
                                        combine: { $0 + $1.size.height })

    tableView.frame.size = size
    tableView.contentSize = CGSize(
      width: tableView.frame.size.width,
      height: height - tableView.contentInset.top - tableView.contentInset.bottom)

    ListSpot.configure?(view: tableView)
  }

  /**
   Configure and setup the data source, delegate and additional configuration options for the table view
   */
  func setupTableView() {
    tableView.dataSource = self.listAdapter
    tableView.delegate = self.listAdapter
    tableView.rowHeight = UITableViewAutomaticDimension

    if let separator = component.meta(Key.separator, type: Bool.self) {
      tableView.separatorStyle = separator
        ? .SingleLine
        : .None
    }
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
