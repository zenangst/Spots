// swiftlint:disable weak_delegate

import Cocoa

open class CarouselComponent: NSObject, Gridable {

  /// Return collection view as a scroll view
  open var view: ScrollView {
    return scrollView
  }

  public static var layout: Layout = Layout()

  /// Child components
  public var compositeComponents: [CompositeComponent] = []

  public struct Key {
    public static let minimumInteritemSpacing = "item-spacing"
    public static let minimumLineSpacing = "line-spacing"
    public static let titleFontSize = "title-font-size"
    public static let titleLeftMargin = "title-left-margin"
    public static let titleTopInset = "title-top-inset"
    public static let titleBottomInset = "title-bottom-inset"
    public static let titleLeftInset = "title-left-inset"
    public static let titleTextColor = "title-text-color"
  }

  public struct Default {
    public static var titleFontSize: CGFloat = 18.0
    public static var titleLeftInset: CGFloat = 0.0
    public static var titleTopInset: CGFloat = 10.0
    public static var titleBottomInset: CGFloat = 10.0
    public static var titleTextColor: String = "000000"
    /// Default section inset top
    public static var sectionInsetTop: CGFloat = 0.0
    /// Default section inset left
    public static var sectionInsetLeft: CGFloat = 0.0
    /// Default section inset right
    public static var sectionInsetRight: CGFloat = 0.0
    /// Default section inset bottom
    public static var sectionInsetBottom: CGFloat = 0.0
    /// Default default minimum interitem spacing
    public static var minimumInteritemSpacing: CGFloat = 0.0
    /// Default minimum line spacing
    public static var minimumLineSpacing: CGFloat = 0.0
  }

  /// A Registry struct that contains all register components, used for resolving what UI component to use
  open static var views = Registry()

  /// A Registry struct that contains all register components, used for resolving what UI component to use
  open static var grids = GridRegistry()

  open static var configure: ((_ view: NSCollectionView) -> Void)?

  open static var defaultGrid: NSCollectionViewItem.Type = NSCollectionViewItem.self

  open static var defaultView: View.Type = NSView.self

  open static var defaultKind: StringConvertible = ComponentModel.Kind.carousel.string

  /// A ComponentDelegate that is used for the CarouselComponent
  open weak var delegate: ComponentDelegate?

  open var model: ComponentModel
  open var configure: ((ItemConfigurable) -> Void)? {
    didSet {
      guard let configure = configure else { return }
      for case let cell as ItemConfigurable in collectionView.visibleItems() {
        configure(cell)
      }
    }
  }

  open fileprivate(set) var stateCache: StateCache?

  open var gradientLayer: CAGradientLayer?

  open lazy var layout: NSCollectionViewLayout = NSCollectionViewFlowLayout()

  open lazy var titleView: NSTextField = {
    let titleView = NSTextField()
    titleView.isEditable = false
    titleView.isSelectable = false
    titleView.isBezeled = false
    titleView.drawsBackground = false
    titleView.textColor = NSColor.gray

    return titleView
  }()

  open lazy var scrollView: ScrollView = ScrollView()
  open var collectionView: CollectionView

  lazy var lineView: NSView = {
    let lineView = NSView()
    lineView.frame.size.height = 1
    lineView.wantsLayer = true
    lineView.layer?.backgroundColor = NSColor.gray.withAlphaComponent(0.2).cgColor

    return lineView
  }()

  public var userInterface: UserInterface?
  var componentDataSource: DataSource?
  var componentDelegate: Delegate?

  /// A required initializer to instantiate a CarouselComponent with a model.
  ///
  /// - parameter component: A component
  ///
  /// - returns: An initialized carousel spot.
  public required init(model: ComponentModel) {
    self.model = model

    if self.model.layout == nil {
      self.model.layout = type(of: self).layout
    }

    self.collectionView = CollectionView()
    super.init()
    self.userInterface = collectionView
    self.model.layout?.configure(component: self)
    self.componentDataSource = DataSource(component: self)
    self.componentDelegate = Delegate(component: self)

    if model.kind.isEmpty {
      self.model.kind = ComponentModel.Kind.carousel.string
    }

    registerDefault(view: CarouselComponentCell.self)
    registerComposite(view: GridComposite.self)
    registerAndPrepare()
    setupCollectionView()

    if let layout = layout as? FlowLayout {
      layout.scrollDirection = .horizontal

      if !model.title.isEmpty {
        configureTitleView(layout.sectionInset)
      }
    }

    scrollView.addSubview(titleView)
    scrollView.addSubview(lineView)
    scrollView.documentView = collectionView
  }

  /// Instantiate a CarouselComponent with a cache key.
  ///
  /// - parameter cacheKey: A unique cache key for the CoreComponent object.
  ///
  /// - returns: An initialized carousel spot.
  public convenience init(cacheKey: String) {
    let stateCache = StateCache(key: cacheKey)

    self.init(model: ComponentModel(stateCache.load()))
    self.stateCache = stateCache
  }

  deinit {
    collectionView.delegate = nil
    collectionView.dataSource = nil
    componentDataSource = nil
    componentDelegate = nil
    userInterface = nil
  }

  /// Configure collection view delegate, data source and layout
  open func setupCollectionView() {
    collectionView.isSelectable = true
    collectionView.backgroundColors = [NSColor.clear]

    let view = NSView()
    collectionView.backgroundView = view
    collectionView.dataSource = componentDataSource
    collectionView.delegate = componentDelegate
    collectionView.collectionViewLayout = layout
  }

  open func layout(_ size: CGSize) {
    var layoutInsets = EdgeInsets()

    if let layout = layout as? NSCollectionViewFlowLayout {
      layout.sectionInset.top = model.meta(GridableMeta.Key.sectionInsetTop, Default.sectionInsetTop) + titleView.frame.size.height + 8
      layoutInsets = layout.sectionInset
    }

    scrollView.frame.size.height = (model.items.first?.size.height ?? layoutInsets.top) + layoutInsets.top + layoutInsets.bottom
    collectionView.frame.size.height = scrollView.frame.size.height
    gradientLayer?.frame.size.height = scrollView.frame.size.height

    if !model.title.isEmpty {
      configureTitleView(layoutInsets)
    }

    if let componentLayout = model.layout {
      if componentLayout.span > 0 {
        model.items.enumerated().forEach {
          model.items[$0.offset].size.width = size.width / CGFloat(componentLayout.span)
        }
      } else if componentLayout.span == 1 {
        scrollView.frame.size.width = size.width - layoutInsets.right
        scrollView.scrollingEnabled = (model.items.count > 1)
        scrollView.hasHorizontalScroller = (model.items.count > 1)
        model.items.enumerated().forEach {
          model.items[$0.offset].size.width = size.width / CGFloat(componentLayout.span)
        }
        layout.invalidateLayout()
      }
    }
  }

  /// Setup CoreComponent component with base size
  ///
  /// - parameter size: The size of the superview
  open func setup(_ size: CGSize) {
    if let layout = model.layout {
      if layout.span > 0 {
        model.items.enumerated().forEach {
          model.items[$0.offset].size.width = size.width / CGFloat(layout.span)
        }
      }
    }

    layout(size)
    CarouselComponent.configure?(collectionView)
  }

  fileprivate func configureTitleView(_ layoutInsets: EdgeInsets) {
    titleView.stringValue = model.title
    titleView.sizeToFit()
    titleView.font = NSFont.systemFont(ofSize: model.meta(Key.titleFontSize, Default.titleFontSize))
    titleView.sizeToFit()
    titleView.frame.size.width = collectionView.frame.width - layoutInsets.right - layoutInsets.left
    lineView.frame.size.width = scrollView.frame.size.width - (model.meta(Key.titleLeftMargin, titleView.frame.origin.x) * 2)
    lineView.frame.origin.x = model.meta(Key.titleLeftMargin, titleView.frame.origin.x)
    titleView.frame.origin.x = collectionView.frame.origin.x + model.meta(Key.titleLeftInset, Default.titleLeftInset)
    titleView.frame.origin.x = model.meta(Key.titleLeftMargin, titleView.frame.origin.x)
    titleView.frame.origin.y = model.meta(Key.titleTopInset, Default.titleTopInset) - model.meta(Key.titleBottomInset, Default.titleBottomInset)
    lineView.frame.origin.y = titleView.frame.maxY + 5
    collectionView.frame.size.height = scrollView.frame.size.height + titleView.frame.size.height
  }

  public func sizeForItem(at indexPath: IndexPath) -> CGSize {

    var width: CGFloat

    if let layout = model.layout {
      width = layout.span > 0
        ? collectionView.frame.width / CGFloat(layout.span)
        : collectionView.frame.width
    } else {
      width = collectionView.frame.width
    }

    if let layout = layout as? NSCollectionViewFlowLayout {
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
  }
}
