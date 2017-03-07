// swiftlint:disable weak_delegate

import Cocoa

open class ListSpot: NSObject, Listable {

  /// Return collection view as a scroll view
  open var view: ScrollView {
    return scrollView
  }

  public static var layout: Layout = Layout(span: 1.0)

  /// Child spots
  public var compositeSpots: [CompositeSpot] = []

  public struct Key {
    public static let titleSeparator = "title-separator"
    public static let titleFontSize = "title-font-size"
    public static let titleTopInset = "title-top-inset"
    public static let titleBottomInset = "title-bottom-inset"
    public static let titleLeftInset = "title-left-inset"
    public static let contentInsetsTop = "inset-top"
    public static let contentInsetsLeft = "inset-left"
    public static let contentInsetsBottom = "inset-bottom"
    public static let contentInsetsRight = "inset-right"
    public static let doubleAction = "double-click"
  }

  public struct Default {
    public static var titleSeparator: Bool = true
    public static var titleFontSize: CGFloat = 18.0
    public static var titleLeftInset: CGFloat = 0.0
    public static var titleTopInset: CGFloat = 10.0
    public static var titleBottomInset: CGFloat = 10.0
    public static var contentInsetsTop: CGFloat = 0.0
    public static var contentInsetsLeft: CGFloat = 0.0
    public static var contentInsetsBottom: CGFloat = 0.0
    public static var contentInsetsRight: CGFloat = 0.0
  }

  /// A Registry struct that contains all register components, used for resolving what UI component to use
  open static var views = Registry()
  open static var configure: ((_ view: NSTableView) -> Void)?
  open static var defaultView: View.Type = ListSpotItem.self
  open static var defaultKind: StringConvertible = ComponentModel.Kind.list.string

  /// A SpotsDelegate that is used for the ListSpot
  open weak var delegate: SpotsDelegate?

  /// A component struct used as configuration and data source for the ListSpot
  open var component: ComponentModel
  open var configure: ((ItemConfigurable) -> Void)? {
    didSet {
      guard let configure = configure else { return }
      let range = tableView.rows(in: scrollView.contentView.visibleRect)
      (range.location..<range.length).forEach { i in
        if let view = tableView.rowView(atRow: i, makeIfNecessary: false) as? ItemConfigurable {
          configure(view)
        }
      }
    }
  }

  open fileprivate(set) var stateCache: StateCache?

  open lazy var scrollView: ScrollView = {
    let scrollView = ScrollView()
    scrollView.documentView = NSView()

    return scrollView
  }()

  open lazy var titleView: NSTextField = {
    let titleView = NSTextField()
    titleView.isEditable = false
    titleView.isSelectable = false
    titleView.isBezeled = false
    titleView.textColor = NSColor.gray
    titleView.drawsBackground = false

    return titleView
  }()

  open lazy var tableView: NSTableView = {
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

    return tableView
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

  public var userInterface: UserInterface?
  var spotDataSource: DataSource?
  var spotDelegate: Delegate?

  public required init(component: ComponentModel) {
    self.component = component

    if self.component.layout == nil {
      self.component.layout = type(of: self).layout
    }

    super.init()
    self.userInterface = tableView
    self.component.layout?.configure(spot: self)
    self.spotDataSource = DataSource(spot: self)
    self.spotDelegate = Delegate(spot: self)

    if component.kind.isEmpty {
      self.component.kind = ComponentModel.Kind.list.string
    }

    scrollView.contentView.addSubview(tableView)
    configureLayout(component)
    registerDefault(view: ListSpotItem.self)
    registerComposite(view: ListComposite.self)
  }

  public convenience init(cacheKey: String) {
    let stateCache = StateCache(key: cacheKey)

    self.init(component: ComponentModel(stateCache.load()))
    self.stateCache = stateCache
  }

  deinit {
    tableView.delegate = nil
    tableView.dataSource = nil
    spotDataSource = nil
    spotDelegate = nil
    userInterface = nil
  }

  open func doubleAction(_ sender: Any?) {
    guard let item = item(at: tableView.clickedRow), component.meta(Key.doubleAction, type: Bool.self) == true else { return }
    delegate?.spotable(self, itemSelected: item)
  }

  open func action(_ sender: Any?) {
    guard let item = item(at: tableView.clickedRow), component.meta(Key.doubleAction, false) == false else { return }
    delegate?.spotable(self, itemSelected: item)
  }

  open func layout(_ size: CGSize) {
    scrollView.contentInsets.top = component.meta(Key.contentInsetsTop, Default.contentInsetsTop)
    scrollView.contentInsets.left = component.meta(Key.contentInsetsLeft, Default.contentInsetsLeft)
    scrollView.contentInsets.bottom = component.meta(Key.contentInsetsBottom, Default.contentInsetsBottom)
    scrollView.contentInsets.right = component.meta(Key.contentInsetsRight, Default.contentInsetsRight)

    if !component.title.isEmpty {
      configureTitleView()
    }

    tableView.sizeToFit()
    scrollView.frame.size.width = size.width
    scrollView.frame.size.height = tableView.frame.height + scrollView.contentInsets.top + scrollView.contentInsets.bottom
  }

  open func setup(_ size: CGSize) {
    component.items.enumerated().forEach {
      component.items[$0.offset].size.width = size.width
    }

    tableView.frame.size = size
    prepareItems()
    tableView.dataSource = spotDataSource
    tableView.delegate = spotDelegate
    tableView.target = self
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

    layout(size)
    ListSpot.configure?(tableView)
  }

  fileprivate func configureTitleView() {
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

  open func register() {
    for (identifier, item) in type(of: self).views.storage {
      switch item {
      case .classType(_): break
      case .nib(let nib):
        self.tableView.register(nib, forIdentifier: identifier)
      }
    }
  }

  public func afterUpdate() {
    /// This is to set the proper height after reloading a list when initially it didn't contain any items.
    layout(view.frame.size)
  }
}
