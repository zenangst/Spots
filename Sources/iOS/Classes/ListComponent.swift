// swiftlint:disable weak_delegate

import UIKit

/// A CoreComponent object that uses UITableView to render its items
open class ListComponent: NSObject, Listable {

  public static var layout: Layout = Layout(span: 1.0)

  /// Keys for meta data lookup
  public struct Key {
    /// The meta key for setting the header height
    public static let headerHeight = "headerHeight"
    /// A meta key used for enabling and disabling separator style
    public static let separator = "separator"
  }

  /// A Registry object that holds identifiers and classes for cells used in the ListComponent
  open static var views: Registry = Registry()

  /// A configuration closure that is run in setup(_:)
  open static var configure: ((_ view: UITableView) -> Void)?

  /// A Registry object that holds identifiers and classes for headers used in the ListComponent
  open static var headers = Registry()

  /// A component struct used as configuration and data source for the ListComponent
  open var model: ComponentModel

  /// A SpotsFocusDelegate object
  weak public var focusDelegate: ComponentFocusDelegate?

  /// Child components
  public var compositeComponents: [CompositeComponent] = []

  /// A configuration closure
  open var configure: ((ItemConfigurable) -> Void)? {
    didSet {
      configureClosureDidChange()
    }
  }

  /// A ComponentDelegate that is used for the ListComponent
  open weak var delegate: ComponentDelegate?

  /// A UITableView, used as the main UI component for a ListComponent
  open lazy var tableView = UITableView()

  /// A StateCache for the ListComponent
  open fileprivate(set) var stateCache: StateCache?

  public var userInterface: UserInterface?
  var componentDataSource: DataSource?
  var componentDelegate: Delegate?

  // MARK: - Initializers

  /// A required initializer to instantiate a ListComponent with a model.
  ///
  /// - parameter component: A model.
  ///
  /// - returns: An initialized list component with model.
  public required init(model: ComponentModel) {
    self.model = model

    if self.model.layout == nil {
      self.model.layout = type(of: self).layout
    }

    super.init()
    self.userInterface = self.tableView
    self.model.layout?.configure(component: self)
    self.componentDataSource = DataSource(component: self)
    self.componentDelegate = Delegate(component: self)

    if model.kind.isEmpty {
      self.model.kind = ComponentModel.Kind.list.string
    }

    registerDefault(view: ListComponentCell.self)
    registerComposite(view: ListComposite.self)
    setupTableView()
  }

  /// A convenience init for initializing a ListComponent with a custom tableview, title and a kind.
  ///
  /// - parameter tableView: A UITableView.
  /// - parameter title:     A string that is used as a title for the ListComponent.
  /// - parameter kind:      An identifier to determine which kind should be set on the ComponentModel.
  /// - parameter kind:      An identifier to determine which kind should be set on the ComponentModel.
  ///
  /// - returns: An initialized list component with model.
  public convenience init(tableView: UITableView? = nil, title: String = "",
                          kind: String = "list", header: Item) {
    self.init(model: ComponentModel(title: title, header: header, kind: kind, span: 1.0))

    if let tableView = tableView {
      self.tableView = tableView
      self.userInterface = tableView
    }

    setupTableView()
  }

  /// Instantiate a ListComponent with a cache key.
  ///
  /// - parameter cacheKey: A unique cache key for the CoreComponent object.
  ///
  /// - returns: An initialized list component.
  public convenience init(cacheKey: String, tableView: UITableView? = nil) {
    let stateCache = StateCache(key: cacheKey)

    self.init(model: ComponentModel(stateCache.load()))
    self.stateCache = stateCache

    if let tableView = tableView {
      self.tableView = tableView
      self.userInterface = tableView
    }

    setupTableView()
  }

  // MARK: - Setup

  /// Setup CoreComponent component with base size.
  ///
  /// - parameter size: The size of the superview.
  open func setup(_ size: CGSize) {
    var height: CGFloat = model.meta(Key.headerHeight, 0.0)
    for item in model.items {
      height += item.size.height
    }

    tableView.frame.size = size
    tableView.frame.size.width = size.width - (tableView.contentInset.left)
    tableView.frame.origin.x = size.width / 2 - tableView.frame.width / 2
    tableView.contentSize = CGSize(
      width: tableView.frame.size.width,
      height: height - tableView.contentInset.top - tableView.contentInset.bottom)

    prepareItems()

    ListComponent.configure?(tableView)
  }

  deinit {
    componentDataSource = nil
    componentDelegate = nil
    userInterface = nil
  }

  /// Configure and setup the data source, delegate and additional configuration options for the table view.
  public func setupTableView() {
    register()
    tableView.dataSource = componentDataSource
    tableView.delegate = componentDelegate
    tableView.rowHeight = UITableViewAutomaticDimension

    #if os(iOS)
      if let separator = model.meta(Key.separator, type: Bool.self) {
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
