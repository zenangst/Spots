import UIKit
import Brick

/// A Spotable object that uses UITableView to render its items
open class ListSpot: NSObject, Listable {

  public static var layout: Layout = Layout(span: 1.0)

  /// Keys for meta data lookup
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

  /// A SpotsFocusDelegate object
  weak public var focusDelegate: SpotsFocusDelegate?

  /// Child spots
  public var compositeSpots: [CompositeSpot] = []

  /// A configuration closure
  open var configure: ((SpotConfigurable) -> Void)? {
    didSet {
      guard let configure = configure else { return }
      for case let cell as SpotConfigurable in tableView.visibleCells {
        configure(cell)
      }
    }
  }

  /// A SpotsDelegate that is used for the ListSpot
  open weak var delegate: SpotsDelegate?

  /// A UITableView, used as the main UI component for a ListSpot
  open lazy var tableView = UITableView()

  /// A StateCache for the ListSpot
  open fileprivate(set) var stateCache: StateCache?

  /// Indicator to calculate the height based on content
  open var usesDynamicHeight = true

  public var userInterface: UserInterface?
  var spotDataSource: DataSource?
  var spotDelegate: Delegate?

  // MARK: - Initializers

  /// A required initializer to instantiate a ListSpot with a component.
  ///
  /// - parameter component: A component.
  ///
  /// - returns: An initialized list spot with component.
  public required init(component: Component) {
    self.component = component

    if self.component.layout == nil {
      self.component.layout = type(of: self).layout
    }

    super.init()
    self.userInterface = self.tableView
    self.component.layout?.configure(spot: self)
    self.spotDataSource = DataSource(spot: self)
    self.spotDelegate = Delegate(spot: self)

    if component.kind.isEmpty {
      self.component.kind = Component.Kind.List.string
    }

    registerDefault(view: ListSpotCell.self)
    registerComposite(view: ListComposite.self)
    setupTableView()
    prepareItems()
  }

  /// A convenience init for initializing a ListSpot with a custom tableview, title and a kind.
  ///
  /// - parameter tableView: A UITableView.
  /// - parameter title:     A string that is used as a title for the ListSpot.
  /// - parameter kind:      An identifier to determine which kind should be set on the Component.
  /// - parameter kind:      An identifier to determine which kind should be set on the Component.
  ///
  /// - returns: An initialized list spot with component.
  public convenience init(tableView: UITableView? = nil, title: String = "",
                          kind: String = "list", header: String = "") {
    self.init(component: Component(title: title, header: header, kind: kind, span: 1.0))

    if let tableView = tableView {
      self.tableView = tableView
      self.userInterface = tableView
    }

    setupTableView()
  }

  /// Instantiate a ListSpot with a cache key.
  ///
  /// - parameter cacheKey: A unique cache key for the Spotable object.
  ///
  /// - returns: An initialized list spot.
  public convenience init(cacheKey: String, tableView: UITableView? = nil) {
    let stateCache = StateCache(key: cacheKey)

    self.init(component: Component(stateCache.load()))
    self.stateCache = stateCache

    if let tableView = tableView {
      self.tableView = tableView
      self.userInterface = tableView
    }

    setupTableView()
  }

  // MARK: - Setup

  /// Setup Spotable component with base size.
  ///
  /// - parameter size: The size of the superview.
  open func setup(_ size: CGSize) {
    var height: CGFloat = component.meta(Key.headerHeight, 0.0)
    for item in component.items {
      height += item.size.height
    }

    tableView.frame.size = size
    tableView.frame.size.width = size.width - (tableView.contentInset.left)
    tableView.frame.origin.x = size.width / 2 - tableView.frame.width / 2
    tableView.contentSize = CGSize(
      width: tableView.frame.size.width,
      height: height - tableView.contentInset.top - tableView.contentInset.bottom)

    ListSpot.configure?(tableView)
  }

  deinit {
    spotDataSource = nil
    spotDelegate = nil
    userInterface = nil
  }

  /// Configure and setup the data source, delegate and additional configuration options for the table view.
  public func setupTableView() {
    register()
    tableView.dataSource = spotDataSource
    tableView.delegate = spotDelegate
    tableView.rowHeight = UITableViewAutomaticDimension

    #if os(iOS)
      if let separator = component.meta(Key.separator, type: Bool.self) {
        tableView.separatorStyle = separator
          ? .singleLine
          : .none
      }
    #endif

    /// On iOS 8 and prior, the second cell always receives the same height as the first cell. Setting estimatedRowHeight magically fixes this issue. The value being set is not relevant.
    if #available(iOS 9, *) {
      return
    } else {
      tableView.estimatedRowHeight = 10
    }
  }

  // MARK: - Spotable

  /// Register all identifier to UITableView.
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

  /// Register header view with identifier
  ///
  /// - parameter header:     The view type that you want to register.
  /// - parameter identifier: A string identifier for the header that you want to register.
  open static func register(header: View.Type, identifier: StringConvertible) {
    self.headers.storage[identifier.string] = Registry.Item.classType(header)
  }

  /// Register default header
  ///
  /// parameter header: The view type that you want to register as default header.
  open static func register(defaultHeader header: View.Type) {
    self.headers.storage[self.views.defaultIdentifier] = Registry.Item.classType(header)
  }
}
