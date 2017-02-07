#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif

public class Spot: NSObject, Spotable {

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

  open lazy var pageControl = UIPageControl()
  open lazy var backgroundView = UIView()

  #if os(OSX)
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
  #else
  var collectionViewLayout: CollectionLayout?

  public var view: ScrollView {
    if let userInterface = userInterface as? ScrollView {
      return userInterface
    }

    let UIComponent: ScrollView

    switch componentKind {
    case .carousel, .grid, .row:
      let collectionViewLayout = CollectionLayout()
      component.layout?.configure(collectionViewLayout: collectionViewLayout)

      collectionViewLayout.scrollDirection = componentKind == .carousel
        ? .horizontal : .vertical

      let collectionView = CollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
      self.userInterface = collectionView
      UIComponent = collectionView
    case .list:
      let tableView = TableView()
      self.userInterface = tableView
      UIComponent = tableView
    }

    return UIComponent
  }
  #endif

  public var tableView: TableView? {
    return userInterface as? TableView
  }

  public var collectionView: CollectionView? {
    return userInterface as? CollectionView
  }

  public required init(component: Component) {
    var component = component
    if component.kind.isEmpty {
      component.kind = Spot.defaultKind
    }

    self.component = component

    if let componentKind = Component.Kind(rawValue: component.kind) {
      self.componentKind = componentKind
    }

    super.init()

    self.spotDataSource = DataSource(spot: self)
    self.spotDelegate = Delegate(spot: self)

    configureUserInterface(with: component,
                           userInterface: self.view as? UserInterface)

    if let componentLayout = component.layout {
      configure(with: componentLayout)
    }

    prepareItems()
  }

  deinit {
    spotDataSource = nil
    spotDelegate = nil
    userInterface = nil
  }

  public func configure(with layout: Layout) {
    layout.configure(spot: self)
  }

  @discardableResult public func configureUserInterface(with component: Component, userInterface: UserInterface? = nil) {
    userInterface?.register()

    #if os(OSX)
      if let tableView = self.table {
        scrollView.contentView.addSubview(tableView)
      } else if let collectionView = self.collection {
        scrollView.contentView.addSubview(collectionView)
      }
    #else
      if let collectionView = self.collectionView {
        collectionView.backgroundView = backgroundView
      }
    #endif
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

  public func setup(_ size: CGSize) {
    type(of: self).configure?(view)

    if let tableView = self.tableView {
      setupTableView(tableView, with: size)
    } else if let collectionView = self.collectionView {
      setupCollectionView(collectionView, with: size)
    }

    layout(size)
  }

  public func setupTableView(_ tableView: TableView, with size: CGSize) {
    var height: CGFloat = 0.0
    for item in component.items {
      height += item.size.height
    }

    tableView.frame.size = size
    tableView.frame.size.width = size.width - (tableView.contentInset.left)
    tableView.frame.origin.x = size.width / 2 - tableView.frame.width / 2
    tableView.contentSize = CGSize(
      width: tableView.frame.size.width,
      height: height - tableView.contentInset.top - tableView.contentInset.bottom)
  }

  public func setupCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    collectionView.frame.size.width = size.width
    #if !os(OSX)
      guard let layout = collectionView.collectionViewLayout as? CollectionLayout else {
        return
      }

      switch layout.scrollDirection {
      case .horizontal:
        setupHorizontalCollectionView(collectionView, with: size)
      case .vertical:
        setupVerticalCollectionView(collectionView, with: size)
      }
    #endif
  }

  public func setupHorizontalCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    guard let layout = collectionView.collectionViewLayout as? GridableLayout else {
      return
    }

    collectionView.isScrollEnabled = true
    prepareItems()
    configurePageControl()

    if collectionView.contentSize.height > 0 {
      collectionView.frame.size.height = collectionView.contentSize.height
    } else {
      collectionView.frame.size.height = component.items.sorted(by: {
        $0.size.height > $1.size.height
      }).first?.size.height ?? 0

      if collectionView.frame.size.height > 0 {
        collectionView.frame.size.height += layout.sectionInset.top + layout.sectionInset.bottom
      }
    }

    if !component.header.isEmpty {
      let resolve = type(of: self).headers.make(component.header)
      layout.headerReferenceSize.width = collectionView.frame.size.width
      layout.headerReferenceSize.height = resolve?.view?.frame.size.height ?? 0.0
    }

    CarouselSpot.configure?(collectionView, layout)

    collectionView.frame.size.height += layout.headerReferenceSize.height

    if let componentLayout = component.layout {
      collectionView.frame.size.height += CGFloat(componentLayout.inset.top + componentLayout.inset.bottom)
    }

    if let pageIndicatorPlacement = component.layout?.pageIndicatorPlacement {
      switch pageIndicatorPlacement {
      case .below:
        layout.sectionInset.bottom += pageControl.frame.height
        pageControl.frame.origin.y = collectionView.frame.height
      case .overlay:
        let verticalAdjustment = CGFloat(2)
        pageControl.frame.origin.y = collectionView.frame.height - pageControl.frame.height - verticalAdjustment
      }
    }
  }

  public func setupVerticalCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    guard let layout = collectionView.collectionViewLayout as? GridableLayout else {
      return
    }

    collectionView.isScrollEnabled = false
    #if !os(OSX)
      GridSpot.configure?(collectionView, layout)

      if let resolve = type(of: self).headers.make(component.header),
        let view = resolve.view as? Componentable,
        !component.header.isEmpty {

        layout.headerReferenceSize.width = collectionView.frame.size.width
        layout.headerReferenceSize.height = view.frame.size.height

        if layout.headerReferenceSize.width == 0.0 {
          layout.headerReferenceSize.width = size.width
        }

        if layout.headerReferenceSize.height == 0.0 {
          layout.headerReferenceSize.height = view.preferredHeaderHeight
        }
      }
      layout.prepare()
      collectionView.frame.size.height = layout.contentSize.height
    #else
      layout.prepare()
    #endif
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
    tableView.frame.size.width = size.width - (tableView.contentInset.left)
    tableView.frame.origin.x = size.width / 2 - tableView.frame.width / 2

    guard let componentSize = component.size else {
      return
    }
    tableView.frame.size.height = componentSize.height
  }

  func layoutCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    view.frame.size.width = size.width
    if compositeSpots.isEmpty {
      prepareItems()
    }

    guard let layout = collectionView.collectionViewLayout as? CollectionLayout else {
      return
    }

    switch layout.scrollDirection {
    case .horizontal:
      layoutHorizontalCollectionView(collectionView, with: size)
    case .vertical:
      layoutVerticalCollectionView(collectionView, with: size)
    }
  }

  public func layoutHorizontalCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    guard let collectionViewLayout = collectionView.collectionViewLayout as? GridableLayout else {
      return
    }

    collectionViewLayout.prepare()
    collectionViewLayout.invalidateLayout()

    collectionView.frame.size.width = collectionViewLayout.contentSize.width
    collectionView.frame.size.height = collectionViewLayout.contentSize.height
  }

  public func layoutVerticalCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    collectionView.collectionViewLayout.prepare()
    collectionView.collectionViewLayout.invalidateLayout()

    collectionView.frame.size.width = collectionView.collectionViewLayout.collectionViewContentSize.width
    collectionView.frame.size.height = collectionView.collectionViewLayout.collectionViewContentSize.height
  }

  private func configurePageControl() {
    guard let placement = component.layout?.pageIndicatorPlacement else {
      pageControl.removeFromSuperview()
      return
    }

    pageControl.numberOfPages = component.items.count
    pageControl.frame.origin.x = 0
    pageControl.frame.size.height = 22

    switch placement {
    case .below:
      pageControl.frame.size.width = backgroundView.frame.width
      pageControl.pageIndicatorTintColor = .lightGray
      pageControl.currentPageIndicatorTintColor = .gray
      backgroundView.addSubview(pageControl)
    case .overlay:
      pageControl.frame.size.width = view.frame.width
      pageControl.pageIndicatorTintColor = nil
      pageControl.currentPageIndicatorTintColor = nil
      view.addSubview(pageControl)
    }
  }

  public func sizeForItem(at indexPath: IndexPath) -> CGSize {
    let width =  item(at: indexPath)?.size.width ?? 0
    let height = item(at: indexPath)?.size.height ?? 0

    // Never return a negative width
    guard width > -1 else { return CGSize.zero }

    return CGSize(
      width: floor(width),
      height: ceil(height)
    )
  }

  public func register() {

  }
}
