// swiftlint:disable weak_delegate

import Cocoa
import Tailor

public class Spot: NSObject, Spotable {

  public static var layout: Layout = Layout(span: 1.0)
  public static var headers: Registry = Registry()
  public static var views: Registry = Registry()
  public static var defaultKind: String = Component.Kind.list.string

  open static var configure: ((_ view: View) -> Void)?

  weak public var focusDelegate: SpotsFocusDelegate?
  weak public var delegate: SpotsDelegate?

  var headerView: View?
  var footerView: View?

  var headerHeight = CGFloat(0.0)
  var footerHeight = CGFloat(0.0)

  public var component: Component
  public var componentKind: Component.Kind = .list
  public var compositeSpots: [CompositeSpot] = []
  public var configure: ((ItemConfigurable) -> Void)?
  public var spotDelegate: Delegate?
  public var spotDataSource: DataSource?
  public var stateCache: StateCache?
  public var userInterface: UserInterface?
  open var gradientLayer: CAGradientLayer?

  public var responder: NSResponder {
    switch self.userInterface {
    case let tableView as TableView:
      return tableView
    case let collectionView as CollectionView:
      return collectionView
    default:
      return scrollView
    }
  }

  public var nextResponder: NSResponder? {
    get {
      switch self.userInterface {
      case let tableView as TableView:
        return tableView.nextResponder
      case let collectionView as CollectionView:
        return collectionView.nextResponder
      default:
        return scrollView.nextResponder
      }
    }
    set {
      switch self.userInterface {
      case let tableView as TableView:
        tableView.nextResponder = newValue
      case let collectionView as CollectionView:
        collectionView.nextResponder = newValue
      default:
        scrollView.nextResponder = newValue
      }
    }
  }

  public func deselect() {
    switch self.userInterface {
    case let tableView as TableView:
      tableView.deselectAll(nil)
    case let collectionView as CollectionView:
      collectionView.deselectAll(nil)
    default: break
    }
  }

  open lazy var scrollView: ScrollView = ScrollView(documentView: self.documentView)
  open lazy var documentView: FlippedView = FlippedView()

  public var view: ScrollView {
    return scrollView
  }

  public var tableView: TableView? {
    return userInterface as? TableView
  }

  public var collectionView: CollectionView? {
    return userInterface as? CollectionView
  }

  public required init(component: Component, userInterface: UserInterface, kind: Component.Kind) {
    self.component = component
    self.componentKind = kind
    self.userInterface = userInterface

    super.init()

    if component.layout == nil {
      switch kind {
      case .carousel:
        self.component.layout = CarouselSpot.layout
      case .grid:
        self.component.layout = GridSpot.layout
      case .list:
        self.component.layout = ListSpot.layout
        registerDefaultIfNeeded(view: ListSpotItem.self)
      case .row:
        self.component.layout = RowSpot.layout
      default:
        break
      }
    }

    userInterface.register()

    self.spotDataSource = DataSource(spot: self)
    self.spotDelegate = Delegate(spot: self)
  }

  public required convenience init(component: Component) {
    var component = component
    if component.kind.isEmpty {
      component.kind = Spot.defaultKind
    }

    let kind = Component.Kind(rawValue: component.kind) ?? .list
    let userInterface: UserInterface

    if kind == .list {
      userInterface = TableView()
    } else {
      let collectionView = CollectionView(frame: CGRect.zero)
      userInterface = collectionView
    }

    self.init(component: component, userInterface: userInterface, kind: kind)

    if componentKind == .carousel {
      self.component.interaction.scrollDirection = .horizontal
      (collectionView?.collectionViewLayout as? FlowLayout)?.scrollDirection = .horizontal
    }
  }

  public convenience init(cacheKey: String) {
    let stateCache = StateCache(key: cacheKey)

    self.init(component: Component(stateCache.load()))
    self.stateCache = stateCache
  }

  deinit {
    spotDataSource = nil
    spotDelegate = nil
    userInterface = nil
  }

  public func configure(with layout: Layout) {

  }

  fileprivate func configureDataSourceAndDelegate() {
    if let tableView = self.tableView {
      tableView.dataSource = spotDataSource
      tableView.delegate = spotDelegate
    } else if let collectionView = self.collectionView {
      collectionView.dataSource = spotDataSource
      collectionView.delegate = spotDelegate
    }
  }

  public func setup(_ size: CGSize) {
    type(of: self).configure?(view)

    scrollView.frame.size = size

    if let tableView = self.tableView {
      documentView.addSubview(tableView)
      setupTableView(tableView, with: size)
    } else if let collectionView = self.collectionView {
      documentView.addSubview(collectionView)
      setupCollectionView(collectionView, with: size)
    }

    layout(size)
  }

  public func layout(_ size: CGSize) {
    if let tableView = self.tableView {
      layoutTableView(tableView, with: size)
    } else if let collectionView = self.collectionView {
      layoutCollectionView(collectionView, with: size)
    }

    view.layoutSubviews()
  }

  fileprivate func setupTableView(_ tableView: TableView, with size: CGSize) {
    scrollView.addSubview(tableView)

    component.items.enumerated().forEach {
      component.items[$0.offset].size.width = size.width
    }

    tableView.frame.size = size

    prepareItems()

    tableView.dataSource = spotDataSource
    tableView.delegate = spotDelegate
    tableView.backgroundColor = NSColor.clear
    tableView.allowsColumnReordering = false
    tableView.allowsColumnResizing = false
    tableView.allowsColumnSelection = false
    tableView.allowsEmptySelection = true
    tableView.allowsMultipleSelection = false
    tableView.headerView = nil
    tableView.selectionHighlightStyle = .none
    tableView.allowsTypeSelect = true
    tableView.focusRingType = .none
    tableView.target = self
    tableView.action = #selector(self.action(_:))
    tableView.doubleAction = #selector(self.doubleAction(_:))
    tableView.sizeToFit()

    guard tableView.tableColumns.isEmpty else {
      return
    }

    let column = NSTableColumn(identifier: "tableview-column")
    column.maxWidth = 250
    column.width = 250
    column.minWidth = 150

    tableView.addTableColumn(column)
  }

  fileprivate func setupCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    switch componentKind {
    case .carousel:
      setupHorizontalCollectionView(collectionView, with: size)
    default:
      setupVerticalCollectionView(collectionView, with: size)
    }
  }

  fileprivate func setupHorizontalCollectionView(_ collectionView: CollectionView, with size: CGSize) {

  }

  fileprivate func setupVerticalCollectionView(_ collectionView: CollectionView, with size: CGSize) {

  }

  fileprivate func layoutTableView(_ tableView: TableView, with size: CGSize) {
    tableView.frame.origin.y = headerHeight
    tableView.sizeToFit()
    tableView.frame.size.width = size.width

    if let layout = component.layout {
      tableView.frame.origin.x = CGFloat(layout.inset.left)
      tableView.frame.size.width -= CGFloat(layout.inset.left + layout.inset.right)
    }

    scrollView.frame.size.height = tableView.frame.height + headerHeight + footerHeight
  }

  fileprivate func layoutCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    if componentKind == .carousel {
      layoutHorizontalCollectionView(collectionView, with: size)
    } else {
      layoutVerticalCollectionView(collectionView, with: size)
    }
  }

  fileprivate func layoutHorizontalCollectionView(_ collectionView: CollectionView, with size: CGSize) {

  }

  fileprivate func layoutVerticalCollectionView(_ collectionView: CollectionView, with size: CGSize) {

  }

  func registerDefaultIfNeeded(view: View.Type) {
    guard Configuration.views.storage[Configuration.views.defaultIdentifier] == nil else {
      return
    }

    Configuration.views.defaultItem = Registry.Item.classType(view)
  }

  open func doubleAction(_ sender: Any?) {
    guard let tableView = tableView,
      let item = item(at: tableView.clickedRow) else {
      return
    }
    delegate?.spotable(self, itemSelected: item)
  }

  open func action(_ sender: Any?) {
    guard let tableView = tableView,
      let item = item(at: tableView.clickedRow) else {
        return
    }
    delegate?.spotable(self, itemSelected: item)
  }

  public func register() {

  }
}
