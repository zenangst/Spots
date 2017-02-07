import Cocoa
import Tailor

public class Spot: NSObject, Spotable {

  public enum LayoutType: String {
    case grid, left, flow
  }

  public struct Key {
    public static let titleSeparator = "title-separator"
    public static let titleFontSize = "title-font-size"
    public static let titleTopInset = "title-top-inset"
    public static let titleBottomInset = "title-bottom-inset"
    public static let titleLeftInset = "title-left-inset"
    public static let doubleAction = "double-click"

    public static let titleLeftMargin = "title-left-margin"
    public static let titleTextColor = "title-text-color"

    public static let layout = "layout"
    public static let gridLayoutMaximumItemWidth = "item-width-max"
    public static let gridLayoutMaximumItemHeight = "item-height-max"
    public static let gridLayoutMinimumItemWidth = "item-min-width"
    public static let gridLayoutMinimumItemHeight = "item-min-height"
  }

  public struct Default {
    public static var gridLayoutMaximumItemWidth = 120
    public static var gridLayoutMaximumItemHeight = 120
    public static var gridLayoutMinimumItemWidth = 80
    public static var gridLayoutMinimumItemHeight = 80

    public static var defaultLayout: String = LayoutType.flow.rawValue

    public static var titleSeparator: Bool = true
    public static var titleFontSize: CGFloat = 18.0
    public static var titleLeftInset: CGFloat = 0.0
    public static var titleTopInset: CGFloat = 10.0
    public static var titleBottomInset: CGFloat = 10.0

    public static var sectionInsetTop: CGFloat = 0.0
    public static var sectionInsetLeft: CGFloat = 0.0
    public static var sectionInsetRight: CGFloat = 0.0
    public static var sectionInsetBottom: CGFloat = 0.0
  }

  /// These are deprecated
  public static var layout: Layout = Layout(span: 1.0)
  public static var headers: Registry = Registry()
  public static var views: Registry = Registry()
  public static var defaultKind: String = Component.Kind.list.string

  open static var configure: ((_ view: View) -> Void)?

  weak public var focusDelegate: SpotsFocusDelegate?
  weak public var delegate: SpotsDelegate?

  public var component: Component
  public var componentKind: Component.Kind = .list
  public var compositeSpots: [CompositeSpot] = []
  public var configure: ((SpotConfigurable) -> Void)?
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

  open lazy var scrollView: ScrollView = {
    let scrollView = ScrollView()
    scrollView.documentView = NSView()
    return scrollView
  }()

  public var view: ScrollView {
    return scrollView
  }

  public var tableView: TableView? {
    return userInterface as? TableView
  }

  public var collectionView: CollectionView? {
    return userInterface as? CollectionView
  }

  open lazy var titleView: NSTextField = {
    let titleView = NSTextField()
    titleView.isEditable = false
    titleView.isSelectable = false
    titleView.isBezeled = false
    titleView.textColor = NSColor.gray
    titleView.drawsBackground = false

    return titleView
  }()

  open lazy var tableColumn: NSTableColumn = {
    let column = NSTableColumn(identifier: "tableview-column")
    column.maxWidth = 250
    column.width = 250
    column.minWidth = 150

    return column
  }()

  lazy var lineView: NSView = {
    let lineView = NSView()
    lineView.frame.size.height = 1
    lineView.wantsLayer = true
    lineView.layer?.backgroundColor = NSColor.gray.withAlphaComponent(0.2).cgColor

    return lineView
  }()

  public required init(component: Component) {
    var component = component
    if component.kind.isEmpty {
      component.kind = Spot.defaultKind
    }

    self.component = component

    if let componentKind = Component.Kind(rawValue: component.kind) {
      self.componentKind = componentKind
    }

    if component.layout == nil {
      switch componentKind {
      case .carousel:
        self.component.layout = CarouselSpot.layout
      case .grid:
        self.component.layout = GridSpot.layout
      case .list:
        self.component.layout = ListSpot.layout
      case .row:
        self.component.layout = RowSpot.layout
      }
    }

    super.init()

    self.spotDataSource = DataSource(spot: self)
    self.spotDelegate = Delegate(spot: self)

    configureUserInterface(with: component)

    if let componentLayout = component.layout {
      configure(with: componentLayout)
    }
  }

  deinit {
    spotDataSource = nil
    spotDelegate = nil
    userInterface = nil
  }

  public func configure(with layout: Layout) {
    layout.configure(spot: self)
  }

  @discardableResult public func configureUserInterface(with component: Component) {
    if componentKind == .list {
      let tableView = NSTableView(frame: CGRect.zero)
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

      userInterface = tableView
    } else {
      let collectionView = CollectionView()
      collectionView.backgroundColors = [NSColor.clear]
      collectionView.isSelectable = true
      collectionView.allowsMultipleSelection = false
      collectionView.allowsEmptySelection = true
      collectionView.layer = CALayer()
      collectionView.wantsLayer = true
      collectionView.collectionViewLayout = Spot.setupLayout(component)
      userInterface = collectionView
    }

    switch componentKind {
    case .list:
      registerDefault(view: ListSpotItem.self)
    default:
      registerDefault(view: GridView.self)
    }

    userInterface?.register()

    if let tableView = self.tableView {
      scrollView.contentView.addSubview(tableView)
    } else if let collectionView = self.collectionView {
      scrollView.contentView.addSubview(collectionView)
    }
    configureDataSourceAndDelegate()
  }

  func configureDataSourceAndDelegate() {
    if let tableView = self.tableView {
      tableView.dataSource = spotDataSource
      tableView.delegate = spotDelegate
    } else if let collectionView = self.collectionView {
      collectionView.dataSource = spotDataSource
      collectionView.delegate = spotDelegate
    }
  }

  fileprivate static func setupLayout(_ component: Component) -> NSCollectionViewLayout {
    let layout: NSCollectionViewLayout

    switch LayoutType(rawValue: component.meta(Key.layout, Default.defaultLayout)) ?? LayoutType.flow {
    case .grid:
      let gridLayout = NSCollectionViewGridLayout()

      gridLayout.maximumItemSize = CGSize(width: component.meta(Key.gridLayoutMaximumItemWidth, Default.gridLayoutMaximumItemWidth),
                                          height: component.meta(Key.gridLayoutMaximumItemHeight, Default.gridLayoutMaximumItemHeight))
      gridLayout.minimumItemSize = CGSize(width: component.meta(Key.gridLayoutMinimumItemWidth, Default.gridLayoutMinimumItemWidth),
                                          height: component.meta(Key.gridLayoutMinimumItemHeight, Default.gridLayoutMinimumItemHeight))
      layout = gridLayout
    case .left:
      let leftLayout = CollectionViewLeftLayout()
      layout = leftLayout
    default:
      let flowLayout = NSCollectionViewFlowLayout()
      flowLayout.scrollDirection = .vertical
      layout = flowLayout
    }

    return layout
  }

  public func setup(_ size: CGSize) {
    scrollView.frame.size.width = size.width
    type(of: self).configure?(view)
    prepareItems()

    if let tableView = self.tableView {
      setupTableView(tableView, with: size)
    } else if let collectionView = self.collectionView {
      setupCollectionView(collectionView, with: size)
    }

    layout(size)
  }

  public func setupTableView(_ tableView: TableView, with size: CGSize) {
    tableView.dataSource = spotDataSource
    tableView.delegate = spotDelegate
    tableView.target = self
    tableView.reloadData()
    tableView.addTableColumn(tableColumn)
    tableView.action = #selector(self.action(_:))
    tableView.doubleAction = #selector(self.doubleAction(_:))
    tableView.sizeToFit()

    if !component.title.isEmpty {
      scrollView.addSubview(titleView)
      if component.meta(Key.titleSeparator, Default.titleSeparator) {
        scrollView.addSubview(lineView)
      }
      configureTitleView()
    }

    ListSpot.configure?(tableView)
  }

  public func setupCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    switch componentKind {
    case .carousel:
      setupHorizontalCollectionView(collectionView, with: size)
    default:
      setupVerticalCollectionView(collectionView, with: size)
    }
  }

  public func setupHorizontalCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    if let layout = component.layout {
      if layout.span > 0 {
        component.items.enumerated().forEach {
          component.items[$0.offset].size.width = size.width / CGFloat(layout.span)
        }
      }
    }
    CarouselSpot.configure?(collectionView)
  }

  public func setupVerticalCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    guard let collectionViewLayout = collectionView.collectionViewLayout else {
      return
    }

    var size = size
    size.height = collectionViewLayout.collectionViewContentSize.height
    collectionViewLayout.invalidateLayout()
    component.size = collectionView.frame.size
  }

  public func layout(_ size: CGSize) {
    if let tableView = self.tableView {
      layoutTableView(tableView, with: size)
    } else if let collectionView = self.collectionView {
      layoutCollectionView(collectionView, with: size)
    }

    view.layoutSubviews()
  }

  func layoutTableView(_ tableView: TableView, with size: CGSize) {
    if !component.title.isEmpty {
      configureTitleView()
    }

    tableView.sizeToFit()
    scrollView.frame.size.width = size.width
    scrollView.frame.size.height = tableView.frame.height + scrollView.contentInsets.top + scrollView.contentInsets.bottom
  }

  func layoutCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    if componentKind == .carousel {
      layoutHorizontalCollectionView(collectionView, with: size)
    } else {
      layoutVerticalCollectionView(collectionView, with: size)
    }
  }

  public func layoutHorizontalCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    var layoutInsets = EdgeInsets()

    if let layout = collectionView.collectionViewLayout as? NSCollectionViewFlowLayout {
      layout.sectionInset.top = component.meta(GridableMeta.Key.sectionInsetTop, Default.sectionInsetTop) + titleView.frame.size.height + 8
      layoutInsets = layout.sectionInset
    }

    scrollView.frame.size.height = (component.items.first?.size.height ?? layoutInsets.top) + layoutInsets.top + layoutInsets.bottom
    collectionView.frame.size.height = scrollView.frame.size.height
    gradientLayer?.frame.size.height = scrollView.frame.size.height

    if !component.title.isEmpty {
      configureTitleView(layoutInsets)
    }

    if let componentLayout = component.layout {
      if componentLayout.span > 0 {
        component.items.enumerated().forEach {
          component.items[$0.offset].size.width = size.width / CGFloat(componentLayout.span)
        }
      } else if componentLayout.span == 1 {
        scrollView.frame.size.width = size.width - layoutInsets.right
        scrollView.scrollingEnabled = (component.items.count > 1)
        scrollView.hasHorizontalScroller = (component.items.count > 1)
        component.items.enumerated().forEach {
          component.items[$0.offset].size.width = size.width / CGFloat(componentLayout.span)
        }
        collectionView.collectionViewLayout?.invalidateLayout()
      }
    }
  }

  public func layoutVerticalCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    guard let collectionViewLayout = collectionView.collectionViewLayout else {
      return
    }

    collectionViewLayout.invalidateLayout()
    var layoutInsets = EdgeInsets()
    if let layout = collectionViewLayout as? NSCollectionViewFlowLayout {
      layout.sectionInset.top = component.meta(GridableMeta.Key.sectionInsetTop, Default.sectionInsetTop) + titleView.frame.size.height + 8
      layoutInsets = layout.sectionInset
    }

    var layoutHeight = collectionViewLayout.collectionViewContentSize.height + layoutInsets.top + layoutInsets.bottom

    if component.items.isEmpty {
      layoutHeight = size.height + layoutInsets.top + layoutInsets.bottom
    }

    scrollView.frame.size.width = size.width - layoutInsets.right
    scrollView.frame.size.height = layoutHeight
    collectionView.frame.size.height = scrollView.frame.size.height - layoutInsets.top + layoutInsets.bottom
    collectionView.frame.size.width = size.width - layoutInsets.right

    if !component.title.isEmpty {
      configureTitleView(layoutInsets)
    }
  }

  public func sizeForItem(at indexPath: IndexPath) -> CGSize {
    var width: CGFloat = 0.0
    var height: CGFloat = 0.0

    width  <- item(at: indexPath)?.size.width
    height <- item(at: indexPath)?.size.height

    return CGSize(
      width: floor(width),
      height: ceil(height)
    )
  }

  func registerDefault(view: View.Type) {
    if Configuration.views.storage[Configuration.views.defaultIdentifier] == nil {
      Configuration.views.defaultItem = Registry.Item.classType(view)
    }
  }

  fileprivate func configureTitleView(_ layoutInsets: EdgeInsets) {
    guard let collectionView = collectionView else {
      return
    }

    titleView.stringValue = component.title
    titleView.sizeToFit()
    titleView.font = NSFont.systemFont(ofSize: component.meta(Key.titleFontSize, Default.titleFontSize))
    titleView.sizeToFit()
    titleView.frame.size.width = collectionView.frame.width - layoutInsets.right - layoutInsets.left
    lineView.frame.size.width = scrollView.frame.size.width - (component.meta(Key.titleLeftMargin, titleView.frame.origin.x) * 2)
    lineView.frame.origin.x = component.meta(Key.titleLeftMargin, titleView.frame.origin.x)
    titleView.frame.origin.x = collectionView.frame.origin.x + component.meta(Key.titleLeftInset, Default.titleLeftInset)
    titleView.frame.origin.x = component.meta(Key.titleLeftMargin, titleView.frame.origin.x)
    titleView.frame.origin.y = component.meta(Key.titleTopInset, Default.titleTopInset) - component.meta(Key.titleBottomInset, Default.titleBottomInset)
    lineView.frame.origin.y = titleView.frame.maxY + 5
    collectionView.frame.size.height = scrollView.frame.size.height + titleView.frame.size.height
  }

  fileprivate func configureTitleView() {
    guard let tableView = tableView else {
      return
    }

    titleView.stringValue = component.title
    titleView.font = NSFont.systemFont(ofSize: component.meta(Key.titleFontSize, Default.titleFontSize))
    titleView.sizeToFit()
    titleView.isEnabled = false
    titleView.frame.origin.x = tableView.frame.origin.x + component.meta(Key.titleLeftInset, Default.titleLeftInset)
    scrollView.contentInsets.top += titleView.frame.size.height * 2
    titleView.frame.origin.y = titleView.frame.size.height / 2

    lineView.frame.size.width = scrollView.frame.size.width - (component.meta(Key.titleLeftInset, Default.titleLeftInset) * 2)
    lineView.frame.origin.x = component.meta(Key.titleLeftInset, Default.titleLeftInset)
    lineView.frame.origin.y = titleView.frame.maxY + 8
  }

  open func doubleAction(_ sender: Any?) {
    guard let tableView = tableView, let item = item(at: tableView.clickedRow), component.meta(Key.doubleAction, type: Bool.self) == true else { return }
    delegate?.spotable(self, itemSelected: item)
  }

  open func action(_ sender: Any?) {
    guard let tableView = tableView, let item = item(at: tableView.clickedRow), component.meta(Key.doubleAction, false) == false else { return }
    delegate?.spotable(self, itemSelected: item)
  }

  public func register() {

  }
}
