import UIKit
import Brick

/// A Spotable object that uses UITableView to render its items
open class ListSpot: NSObject, Listable {

  /**
   *  Keys for meta data lookup
   */
  public struct Key {
    /// The meta key for setting the header height
    public static let headerHeight = "headerHeight"
    /// A meta key used for enabling and disabling separator style
    public static let separator = "separator"
  }

  /// A Registry object that holds identifiers and classes for cells used in the ListSpot
  open static var views: Registry = Registry()

  /// A configuration closure that is run in setup(_:)
  open static var configure: ((_ view: UITableView) -> Void)?

  /// A Registry object that holds identifiers and classes for headers used in the ListSpot
  open static var headers = Registry()

  /// A component struct used as configuration and data source for the ListSpot
  open var component: Component

  /// A configuration closure
  open var configure: ((SpotConfigurable) -> Void)?

  /// A SpotsCompositeDelegate for the GridSpot, used to access composite spots
  open weak var spotsCompositeDelegate: SpotsCompositeDelegate?

  /// A SpotsDelegate that is used for the GridSpot
  open weak var spotsDelegate: SpotsDelegate?

  /// A computed variable for adapters
  open var adapter: SpotAdapter? {
    return listAdapter
  }

  /// A list adapter that is the data source and delegate for the ListSpot
  open lazy var listAdapter: ListAdapter = ListAdapter(spot: self)

  /// A UITableView, used as the main UI component for a ListSpot
  open lazy var tableView = UITableView()

  /// A SpotCache for the ListSpot
  open fileprivate(set) var stateCache: SpotCache?

  /// Indicator to calculate the height based on content
  open var usesDynamicHeight = true

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

    registerDefault(ListSpotCell.self)
    registerComposite(ListComposite.self)
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
    self.init(component: Component(title: title, header: header, kind: kind))

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
  open func setup(_ size: CGSize) {
    registerAndPrepare()
    let height = component.items.reduce(component.meta(Key.headerHeight, 0.0), { $0 + $1.size.height })

    tableView.frame.size = size
    tableView.contentSize = CGSize(
      width: tableView.frame.size.width,
      height: height - tableView.contentInset.top - tableView.contentInset.bottom)

    ListSpot.configure?(tableView)
  }

  /**
   Configure and setup the data source, delegate and additional configuration options for the table view
   */
  func setupTableView() {
    tableView.dataSource = self.listAdapter
    tableView.delegate = self.listAdapter
    tableView.rowHeight = UITableViewAutomaticDimension

    #if os(iOS)
    if let separator = component.meta(Key.separator, type: Bool.self) {
      tableView.separatorStyle = separator
        ? .singleLine
        : .none
    }
    #endif
  }

  // MARK: - Spotable

  /**
   Register all identifier to UITableView
   */
  open func register() {
    for (identifier, item) in type(of: self).views.storage {
      switch item {
      case .classType(let classType):
        self.tableView.register(classType, forCellReuseIdentifier: identifier)
      case .nib(let nib):
        self.tableView.register(nib, forCellReuseIdentifier: identifier)
      }
    }

    for (identifier, item) in type(of: self).headers.storage {
      switch item {
      case .classType(let classType):
        self.tableView.register(classType, forHeaderFooterViewReuseIdentifier: identifier)
      case .nib(let nib):
        self.tableView.register(nib, forHeaderFooterViewReuseIdentifier: identifier)
      }
    }
  }

  /**
   Register header view with identifier

   - parameter header:     The view type that you want to register
   - parameter identifier: A string identifier for the header that you want to register
   */
  open static func register(header: View.Type, identifier: StringConvertible) {
    self.headers.storage[identifier.string] = Registry.Item.classType(header)
  }

  /**
   Register default header

   - parameter header: The view type that you want to register as default header
   */
  open static func register(defaultHeader header: View.Type) {
    self.headers.storage[self.views.defaultIdentifier] = Registry.Item.classType(header)
  }
}
