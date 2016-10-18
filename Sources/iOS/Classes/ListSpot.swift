import UIKit
import Brick

/// A Spotable object that uses UITableView to render its items
open class ListSpot: NSObject, Listable {

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

  /// A configuration closure
  open var configure: ((SpotConfigurable) -> Void)? {
    didSet {
      guard let configure = configure else { return }
      for case let cell as SpotConfigurable in tableView.visibleCells {
        configure(cell)
      }
    }
  }

  /// A CompositeDelegate for the GridSpot, used to access composite spots
  open weak var spotsCompositeDelegate: CompositeDelegate?

  /// A SpotsDelegate that is used for the GridSpot
  open weak var delegate: SpotsDelegate?

  /// A UITableView, used as the main UI component for a ListSpot
  open lazy var tableView = UITableView()

  /// A StateCache for the ListSpot
  open fileprivate(set) var stateCache: StateCache?

  /// Indicator to calculate the height based on content
  open var usesDynamicHeight = true

  // MARK: - Initializers

  /// A required initializer to instantiate a ListSpot with a component.
  ///
  /// - parameter component: A component.
  ///
  /// - returns: An initialized list spot with component.
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
    self.init(component: Component(title: title, header: header, kind: kind))

    if let tableView = tableView {
      self.tableView = tableView
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
    }

    setupTableView()
  }

  // MARK: - Setup

  /// Setup Spotable component with base size.
  ///
  /// - parameter size: The size of the superview.
  open func setup(_ size: CGSize) {
    let height = component.items.reduce(component.meta(Key.headerHeight, 0.0), { $0 + $1.size.height })

    tableView.frame.size = size
    tableView.contentSize = CGSize(
      width: tableView.frame.size.width,
      height: height - tableView.contentInset.top - tableView.contentInset.bottom)

    ListSpot.configure?(tableView)
  }

  /// Configure and setup the data source, delegate and additional configuration options for the table view.
  func setupTableView() {
    tableView.dataSource = self
    tableView.delegate = self
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

/**
 A UITableViewDelegate extension on ListAdapter
 */
extension ListSpot: UITableViewDelegate {

  /// Asks the delegate for the height to use for the header of a particular section.
  ///
  /// - parameter tableView: The table-view object requesting this information.
  /// - parameter heightForHeaderInSection: An index number identifying a section of tableView.
  /// - returns: Returns the `headerHeight` found in `component.meta`, otherwise 0.0.

  public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    let header = type(of: self).headers.make(component.header)
    return (header?.view as? Componentable)?.preferredHeaderHeight ?? 0.0
  }

  /// Asks the data source for the title of the header of the specified section of the table view.
  ///
  /// - parameter tableView: The table-view object asking for the title.
  /// - parameter section: An index number identifying a section of tableView.
  /// - returns: A string to use as the title of the section header. Will return `nil` if title is not present on Component
  public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if let _ = type(of: self).headers.make(component.header) {
      return nil
    }
    return !component.title.isEmpty ? component.title : nil
  }

  /// Tells the delegate that the specified row is now selected.
  ///
  /// - parameter tableView: A table-view object informing the delegate about the new row selection.
  /// - parameter indexPath: An index path locating the new selected row in tableView.
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if let item = self.item(at: indexPath) {
      delegate?.didSelect(item: item, in: self)
    }
  }

  /// Asks the delegate for a view object to display in the header of the specified section of the table view.
  ///
  /// - parameter tableView: The table-view object asking for the view object.
  /// - parameter section: An index number identifying a section of tableView.
  /// - returns: A view object to be displayed in the header of section based on the kind of the ListSpot and registered headers.
  public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard !component.header.isEmpty else { return nil }

    let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: component.header)
    view?.frame.size.height = component.meta(ListSpot.Key.headerHeight, 0.0)
    view?.frame.size.width = tableView.frame.size.width
    (view as? Componentable)?.configure(component)

    return view
  }

  /// Asks the delegate for the height to use for a row in a specified location.
  ///
  /// - parameter tableView: The table-view object requesting this information.
  /// - parameter indexPath: An index path that locates a row in tableView.
  /// - returns:  A nonnegative floating-point value that specifies the height (in points) that row should be based on the view model height, defaults to 0.0.

  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    component.size = CGSize(
      width: tableView.frame.size.width,
      height: tableView.frame.size.height)

    return item(at: indexPath)?.size.height ?? 0
  }
}

/// MARK: - UITableViewDataSource
extension ListSpot : UITableViewDataSource {

  /// Tells the data source to return the number of rows in a given section of a table view. (required)
  ///
  /// - parameter tableView: The table-view object requesting this information.
  /// - parameter section: An index number identifying a section in tableView.
  ///
  /// - returns: The number of rows in section.
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return component.items.count
  }

  /// Asks the data source for a cell to insert in a particular location of the table view. (required)
  ///
  /// - parameter tableView: A table-view object requesting the cell.
  /// - parameter indexPath: An index path locating a row in tableView.
  ///
  /// - returns: An object inheriting from UITableViewCell that the table view can use for the specified row. Will return the default table view cell for the current component based of kind.
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.item < component.items.count {
      component.items[indexPath.item].index = indexPath.row
    }

    let reuseIdentifier = identifier(at: indexPath)
    let cell: UITableViewCell = tableView
      .dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

    guard indexPath.item < component.items.count else { return cell }

    if let composite = cell as? Composable {
      let spots = spotsCompositeDelegate?.resolve(index, itemIndex: (indexPath as NSIndexPath).item)
      composite.configure(&component.items[indexPath.item], spots: spots)
    } else if let cell = cell as? SpotConfigurable {
      cell.configure(&component.items[indexPath.item])

      if component.items[indexPath.item].size.height == 0.0 {
        component.items[indexPath.item].size = cell.preferredViewSize
      }

      configure?(cell)
    }

    return cell
  }
}
