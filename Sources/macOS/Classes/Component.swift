// swiftlint:disable weak_delegate

import Cocoa
import Tailor

@objc(SpotsComponent) public class Component: NSObject {

  public static var layout: Layout = Layout(span: 0.0)
  public static var headers: Registry = Registry()
  public static var views: Registry = Registry()
  public static var defaultKind: ComponentKind = .list

  open static var configure: ((_ view: View) -> Void)?

  weak public var focusDelegate: ComponentFocusDelegate?
  weak public var delegate: ComponentDelegate?

  var headerView: View?
  var footerView: View?

  public var model: ComponentModel
  public var componentKind: ComponentKind = .list
  public var compositeComponents: [CompositeComponent] = []

  public var configure: ((ItemConfigurable) -> Void)? {
    didSet {
      configureClosureDidChange()
    }
  }

  public var componentDelegate: Delegate?
  public var componentDataSource: DataSource?
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

  var headerHeight: CGFloat {
    guard let headerView = headerView else {
      return 0.0
    }

    return headerView.frame.size.height
  }

  var footerHeight: CGFloat {
    guard let footerView = footerView else {
      return 0.0
    }

    return footerView.frame.size.height
  }

  public var view: ScrollView {
    return scrollView
  }

  public var tableView: TableView? {
    return userInterface as? TableView
  }

  public var collectionView: CollectionView? {
    return userInterface as? CollectionView
  }

  public required init(model: ComponentModel, userInterface: UserInterface, kind: ComponentKind = Component.defaultKind) {
    self.model = model
    self.componentKind = kind
    self.userInterface = userInterface

    super.init()

    if model.layout == nil {
      switch kind {
      case .carousel:
        self.model.layout = CarouselComponent.layout
      case .grid:
        self.model.layout = GridComponent.layout
      case .list:
        self.model.layout = ListComponent.layout
      case .row:
        self.model.layout = RowComponent.layout
      }
    }

    registerDefaultIfNeeded(view: ListComponentItem.self)

    userInterface.register()

    self.componentDataSource = DataSource(component: self)
    self.componentDelegate = Delegate(component: self)
  }

  public required convenience init(model: ComponentModel) {
    let userInterface: UserInterface

    if model.kind == .list {
      userInterface = TableView()
    } else {
      let collectionView = CollectionView(frame: CGRect.zero)
      collectionView.collectionViewLayout = GridableLayout()
      userInterface = collectionView
    }

    self.init(model: model, userInterface: userInterface, kind: model.kind)

    if componentKind == .carousel {
      self.model.interaction.scrollDirection = .horizontal
      (collectionView?.collectionViewLayout as? FlowLayout)?.scrollDirection = .horizontal
    }
  }

  public convenience init(cacheKey: String) {
    let stateCache = StateCache(key: cacheKey)

    self.init(model: ComponentModel(stateCache.load()))
    self.stateCache = stateCache
  }

  deinit {
    componentDataSource = nil
    componentDelegate = nil
    userInterface = nil
  }

  fileprivate func configureDataSourceAndDelegate() {
    if let tableView = self.tableView {
      tableView.dataSource = componentDataSource
      tableView.delegate = componentDelegate
    } else if let collectionView = self.collectionView {
      collectionView.dataSource = componentDataSource
      collectionView.delegate = componentDelegate
    }
  }

  public func setup(with size: CGSize) {
    type(of: self).configure?(view)

    scrollView.frame.size = size

    setupHeader(with: &model)
    setupFooter(with: &model)

    configureDataSourceAndDelegate()

    if let tableView = self.tableView {
      documentView.addSubview(tableView)
      setupTableView(tableView, with: size)
    } else if let collectionView = self.collectionView {
      documentView.addSubview(collectionView)
      setupCollectionView(collectionView, with: size)
    }

    layout(with: size)
  }

  public func layout(with size: CGSize) {
    if let tableView = self.tableView {
      layoutTableView(tableView, with: size)
    } else if let collectionView = self.collectionView {
      layoutCollectionView(collectionView, with: size)
    }

    layoutHeaderFooterViews(size)

    view.layoutSubviews()
  }

  fileprivate func setupCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    if let componentLayout = self.model.layout,
      let collectionViewLayout = collectionView.collectionViewLayout as? FlowLayout {
      componentLayout.configure(collectionViewLayout: collectionViewLayout)
    }

    collectionView.frame.size = size

    prepareItems()

    collectionView.backgroundColors = [NSColor.clear]
    collectionView.isSelectable = true
    collectionView.allowsMultipleSelection = false
    collectionView.allowsEmptySelection = true
    collectionView.layer = CALayer()
    collectionView.wantsLayer = true

    let backgroundView = NSView()
    backgroundView.wantsLayer = true
    collectionView.backgroundView = backgroundView

    switch componentKind {
    case .carousel:
      setupHorizontalCollectionView(collectionView, with: size)
    default:
      setupVerticalCollectionView(collectionView, with: size)
    }
  }

  fileprivate func layoutCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    if componentKind == .carousel {
      layoutHorizontalCollectionView(collectionView, with: size)
    } else {
      layoutVerticalCollectionView(collectionView, with: size)
    }
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
    delegate?.component(self, itemSelected: item)
  }

  open func action(_ sender: Any?) {
    guard let tableView = tableView,
      let item = item(at: tableView.clickedRow) else {
        return
    }
    delegate?.component(self, itemSelected: item)
  }

  public func sizeForItem(at indexPath: IndexPath) -> CGSize {
    if let collectionView = collectionView,
      model.interaction.scrollDirection == .horizontal {
      var width: CGFloat

      if let layout = model.layout {
        width = layout.span > 0
          ? collectionView.frame.width / CGFloat(layout.span)
          : collectionView.frame.width
      } else {
        width = collectionView.frame.width
      }

      if let layout = collectionView.collectionViewLayout as? NSCollectionViewFlowLayout {
        width -= layout.sectionInset.left - layout.sectionInset.right
        width -= layout.minimumInteritemSpacing
        width -= layout.minimumLineSpacing
      }

      if model.items[indexPath.item].size.width == 0.0 {
        model.items[indexPath.item].size.width = width
      }

      return CGSize(
        width: ceil(model.items[indexPath.item].size.width),
        height: ceil(model.items[indexPath.item].size.height))
    } else {
      return CGSize(
        width:  item(at: indexPath)?.size.width  ?? 0.0,
        height: item(at: indexPath)?.size.height ?? 0.0
      )
    }
  }

  public func afterUpdate() {
    if let superview = view.superview {
      let size = CGSize(width: superview.frame.width,
                        height: view.frame.height)
      layout(with: size)
    }

    guard !compositeComponents.isEmpty else {
      return
    }
    reload()
  }

  public func register() {

  }
}
