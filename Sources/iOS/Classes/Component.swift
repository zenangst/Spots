// swiftlint:disable weak_delegate

import UIKit

public class Component: NSObject, ComponentHorizontallyScrollable {
  /// The default layout that should be used for components.
  /// It will default to this one if `Layout` is absent during init.
  public static var layout: Layout = Layout(span: 0.0)
  /// A configuration closure that can be used to pinpoint configuration of
  /// views used inside of the component.
  open static var configure: ((Component) -> Void)?
  /// A focus delegate that returns which component is focused.
  weak public var focusDelegate: ComponentFocusDelegate?
  /// A component delegate, used for interaction and to pick up on mutation made to
  /// `self.components`. See `ComponentDelegate` for more information.
  weak public var delegate: ComponentDelegate?
  /// A reference to the header view that should be used for the component.
  var headerView: View?
  /// A reference to the footer view that should be used for the component.
  var footerView: View?
  /// A horizontal scroll view delegate that will invoke methods when a user scrolls
  /// a collection view with horizontal scrolling.
  weak public var carouselScrollDelegate: CarouselScrollDelegate?
  /// A parent component used for composition.
  public var parentComponent: Component? {
    didSet {
      self.view.frame.size.height = self.computedHeight
      self.focusDelegate = parentComponent?.focusDelegate
    }
  }
  /// The component model, it contains all the information for configuring `Component`
  /// interaction, behaviour and look-and-feel. See `ComponentModel` for more information.
  public var model: ComponentModel
  /// An engine that handles mutation of the component model data source.
  public var manager: ComponentManager = ComponentManager()
  /// A collection of composite components, dynamically constructed and mutated based of
  /// the contents of the `.model`.
  public var compositeComponents: [CompositeComponent] = []
  /// A configuration closure that will be invoked when views are added to the component.
  public var configure: ((ItemConfigurable) -> Void)? {
    didSet {
      configureClosureDidChange()
    }
  }
  /// The delegate for the user interface that the component uses to render itself.
  /// Similar to a normal table or collection view delegate.
  public var componentDelegate: Delegate?
  /// The data source for the user interface that the component uses to render itself.
  /// Similar to a normal table or collection view data source.
  public var componentDataSource: DataSource?
  /// A state cache that can be used to keep state across sessions.
  public var stateCache: StateCache?
  /// A computed value that returns the current view as a UserInterface.
  /// UserInterface supports `UITableView` and `UICollectionView`.
  public var userInterface: UserInterface? {
    return self.view as? UserInterface
  }
  /// A regular UIPageControl that is used inside horizontal collection views.
  /// It is enabled by setting `pageIndicatorPlacement` on `Layout`.
  open lazy var pageControl = UIPageControl()
  /// A background view that gets added to `UICollectionView`.
  open lazy var backgroundView = UIView()
  /// This returns the current user interface as a UIScrollView.
  /// It would either be UICollectionView or UITableView.
  /// If you need to target one specific view it is preferred to use `.tableView` and `.collectionView`.
  /// The height of the header view.
  var headerHeight: CGFloat {
    guard let headerView = headerView else {
      return 0.0
    }

    return headerView.frame.size.height
  }
  /// The height of the footer view.
  var footerHeight: CGFloat {
    guard let footerView = footerView else {
      return 0.0
    }

    return footerView.frame.size.height
  }
  public var view: ScrollView
  /// A computed variable that casts the current `userInterface` into a `UITableView`.
  /// It will return `nil` if the model kind is not `.list`.
  public var tableView: TableView? {
    return userInterface as? TableView
  }
  /// A computed variable that casts the current `userInterface` into a `UICollectionView`.
  /// It will return `nil` if the model kind is `.list`.
  public var collectionView: CollectionView? {
    return userInterface as? CollectionView
  }

  /// Default initializer for creating a component.
  ///
  /// - Parameters:
  ///   - model: A `ComponentModel` that is used to configure the interaction, behavior and look-and-feel of the component.
  ///   - view: A scroll view, should either be a `UITableView` or `UICollectionView`.
  ///   - kind: The `kind` defines which user interface the component should render (either UICollectionView or UITableView).
  public required init(model: ComponentModel, view: ScrollView, parentComponent: Component? = nil) {
    self.model = model
    self.view = view
    self.parentComponent = parentComponent

    super.init()

    if model.layout == nil {
      self.model.layout = Component.layout
    }

    registerDefaultIfNeeded(view: DefaultItemView.self)

    userInterface?.register()

    if let componentLayout = self.model.layout,
      let collectionViewLayout = collectionView?.collectionViewLayout as? ComponentFlowLayout {
      componentLayout.configure(collectionViewLayout: collectionViewLayout)
    }

    self.componentDataSource = DataSource(component: self)
    self.componentDelegate = Delegate(component: self)
  }

  /// A convenience init for creating a component with a `ComponentModel`.
  ///
  /// - Parameter model: A component model that is used for constructing and configurating the component.
  public required convenience init(model: ComponentModel) {
    let view = model.kind == .list
      ? TableView()
      : ComponentCollectionView(frame: .zero, collectionViewLayout: CollectionLayout())

    self.init(model: model, view: view)

    (collectionView as? ComponentCollectionView)?.component = self
  }

  /// A convenience init for creating a component with view state functionality.
  ///
  /// - Parameter cacheKey: The unique cache key that should be used for storing and restoring the component.
  public convenience init(cacheKey: String) {
    let stateCache = StateCache(key: cacheKey)

    self.init(model: ComponentModel(stateCache.load()))
    self.stateCache = stateCache
  }

  deinit {
    componentDataSource = nil
    componentDelegate = nil
  }

  /// Setup up the component with a given size, this is usually the parent size when used in a controller context.
  ///
  /// - Parameter size: A `CGSize` that is used to set the frame of the user interface.
  public func setup(with size: CGSize) {
    view.frame.size = size

    setupFooter(with: &model)
    setupHeader(with: &model)

    if let tableView = self.tableView {
      setupTableView(tableView, with: size)
    } else if let collectionView = self.collectionView {
      setupCollectionView(collectionView, with: size)
    }

    layout(with: size)
    configurePageControl()
    Component.configure?(self)

    if let layout = model.layout, layout.infiniteScrolling {
      let size = sizeForItem(at: IndexPath(item: 0, section: 0))
      collectionView?.contentOffset.x = size.width + CGFloat(layout.itemSpacing)
    }
  }

  /// Configure the view frame with a given size.
  ///
  /// - Parameter size: A `CGSize` used to set a new size to the user interface.
  public func layout(with size: CGSize) {
    if let tableView = self.tableView {
      layoutTableView(tableView, with: size)
    } else if let collectionView = self.collectionView {
      layoutCollectionView(collectionView, with: size)
    }

    layoutHeaderFooterViews(size)

    view.layoutSubviews()
  }

  /// This method is invoked by `ComponentCollectionView.layoutSubviews()`.
  /// It is used to invoke `handleInfiniteScrolling` when the users scrolls a horizontal
  /// `Component` with `infiniteScrolling` enabled.
  func layoutSubviews() {
    guard model.kind == .carousel, model.layout?.infiniteScrolling == true else {
      return
    }

    handleInfiniteScrolling()
  }

  /// Manipulates the x content offset when `infiniteScrolling` is enabled on the `Component`.
  /// The `.x` offset is changed when the user reaches the beginning or the end of a `Component`.
  private func handleInfiniteScrolling() {
    let contentWidth = view.contentSize.width - view.frame.size.width
    if view.contentOffset.x < 0.0 {
      view.contentOffset.x = contentWidth
    } else if view.contentOffset.x > contentWidth {
      view.contentOffset.x = 0.0
    }
  }

  /// Setup a collection view with a specific size.
  ///
  /// - Parameters:
  ///   - collectionView: The collection view that should be configured.
  ///   - size: The size that should be used for setting up the collection view.
  fileprivate func setupCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    collectionView.frame.size = size
    collectionView.dataSource = componentDataSource
    collectionView.delegate = componentDelegate
    collectionView.backgroundView = backgroundView
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false

    guard model.kind == .carousel else {
      return
    }

    collectionView.showsHorizontalScrollIndicator = false
    self.model.interaction.scrollDirection = .horizontal
    setupHorizontalCollectionView(collectionView, with: size)
  }

  /// Set new frame to collection view and invalidate the layout.
  ///
  /// - Parameters:
  ///   - collectionView: The collection view that should be configured.
  ///   - size: The size that should be used for setting the new layout for the collection view.
  fileprivate func layoutCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    if compositeComponents.isEmpty {
      prepareItems(recreateComposites: true)
    }

    switch model.interaction.scrollDirection {
    case .horizontal:
      if let pageIndicatorPlacement = model.layout?.pageIndicatorPlacement {
        switch pageIndicatorPlacement {
        case .below:
          pageControl.frame.origin.y = collectionView.frame.height - pageControl.frame.height
        case .overlay:
          let verticalAdjustment = CGFloat(2)
          pageControl.frame.origin.y = collectionView.frame.height - pageControl.frame.height - verticalAdjustment
        }
      }

      layoutHorizontalCollectionView(collectionView, with: size)
    case .vertical:
      layoutVerticalCollectionView(collectionView, with: size)
    }
  }

  /// Register a default item as fallback, only if it is not already defined.
  ///
  /// - Parameter view: The view that should be registred as the default view.
  func registerDefaultIfNeeded(view: View.Type) {
    guard Configuration.views.defaultItem == nil else {
      return
    }

    Configuration.views.defaultItem = Registry.Item.classType(view)
  }

  /// Configure the page control for the component.
  /// Page control is only supported in horizontal collection views.
  func configurePageControl() {
    guard let placement = model.layout?.pageIndicatorPlacement else {
      pageControl.removeFromSuperview()
      return
    }

    pageControl.numberOfPages = model.items.count
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

  /// Get the size of the item at index path.
  ///
  /// - Parameter indexPath: The index path of the item that should be resolved.
  /// - Returns: A `CGSize` based of the `Item`'s width and height.
  public func sizeForItem(at indexPath: IndexPath) -> CGSize {
    return CGSize(
      width:  item(at: indexPath)?.size.width  ?? 0.0,
      height: item(at: indexPath)?.size.height ?? 0.0
    )
  }

  /// Scroll to a specific item based on predicate.
  ///
  /// - parameter predicate: A predicate closure to determine which item to scroll to.
  public func scrollTo(item predicate: ((Item) -> Bool), animated: Bool = true) {
    guard let index = model.items.index(where: predicate) else {
      return
    }

    if let collectionView = collectionView {
      let scrollPosition: UICollectionViewScrollPosition

      if model.interaction.scrollDirection == .horizontal {
        scrollPosition = .centeredHorizontally
      } else {
        scrollPosition = .centeredVertically
      }

      collectionView.scrollToItem(at: .init(item: index, section: 0), at: scrollPosition, animated: animated)
    } else if let tableView = tableView {
      tableView.scrollToRow(at: .init(row: index, section: 0), at: .middle, animated: animated)
    }
  }

  /// This method is invoked after mutations has been performed on a component.
  public func afterUpdate() {
    if !compositeComponents.isEmpty {
      setup(with: view.frame.size)
    }
  }
}
