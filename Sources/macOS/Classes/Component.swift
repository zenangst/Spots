// swiftlint:disable weak_delegate

import Cocoa
import Tailor

@objc(SpotsComponent) public class Component: NSObject {
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
  /// The component model, it contains all the information for configuring `Component`
  /// interaction, behaviour and look-and-feel. See `ComponentModel` for more information.
  public var model: ComponentModel
  /// An engine that handles mutation of the component model data source.
  public var manager: ComponentManager = ComponentManager()
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
  /// UserInterface supports `NSTableView` and `NSCollectionView`.
  public var userInterface: UserInterface?
  /// A gradient layer that can be used to brighten up your background of the component.
  open var gradientLayer: CAGradientLayer?
  /// A computed proxy property that will point to either `.tableView` or `.collectionView`,
  /// based of the contents of the model.
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
  /// A computed proxy property that will rely the call of `nextResponder` to either
  /// `.tableView` or `.collectionview`.
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
  /// A convenience method to deselect all selected views in the component.
  public func deselect() {
    switch self.userInterface {
    case let tableView as TableView:
      tableView.deselectAll(nil)
    case let collectionView as CollectionView:
      collectionView.deselectAll(nil)
    default: break
    }
  }
  /// A scroll view container that is used to construct a unified scrolling experience
  /// when using multiple components inside of a controller.
  open lazy var scrollView: ComponentScrollView = ComponentScrollView()
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
  /// Returns the `.scrollView` property.
  /// This exists so that all platforms have a unified public API.
  public var view: ScrollView {
    return scrollView
  }
  /// A computed variable that casts the current `userInterface` into a `NSTableView`.
  /// It will return `nil` if the model kind is not `.list`.
  public var tableView: TableView? {
    return userInterface as? TableView
  }
  /// A computed variable that casts the current `userInterface` into a `NSCollectionView`.
  /// It will return `nil` if the model kind is `.list`.
  public var collectionView: CollectionView? {
    return userInterface as? CollectionView
  }

  /// Default initializer for creating a component.
  ///
  /// - Parameters:
  ///   - model: A `ComponentModel` that is used to configure the interaction, behavior and look-and-feel of the component.
  ///   - view: A scroll view, should either be a `NSTableView` or `NSCollectionView`.
  ///   - kind: The `kind` defines which user interface the component should render (either NSCollectionView or NSTableView).
  public required init(model: ComponentModel, userInterface: UserInterface, parentComponent: Component? = nil) {
    self.model = model
    self.userInterface = userInterface

    super.init()
    registerDefaultIfNeeded(view: DefaultItemView.self)
    userInterface.register()

    self.componentDataSource = DataSource(component: self)
    self.componentDelegate = Delegate(component: self)
  }

  /// A convenience init for creating a component with a `ComponentModel`.
  ///
  /// - Parameter model: A component model that is used for constructing and configurating the component.
  public required convenience init(model: ComponentModel, userInterface: UserInterface? = nil) {
    var userInterface: UserInterface! = userInterface

    if userInterface == nil, model.kind == .list {
      userInterface = TableView()
    } else {
      let collectionView = CollectionView(frame: CGRect.zero)
      collectionView.collectionViewLayout = ComponentFlowLayout()
      userInterface = collectionView
    }

    self.init(model: model, userInterface: userInterface!)

    scrollView.documentView = userInterface as? View

    if model.kind == .carousel {
      self.model.interaction.scrollDirection = .horizontal
      collectionView?.flowLayout?.scrollDirection = .horizontal
    }
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
    userInterface = nil
  }

  /// Configure user interface data source and delegate.
  fileprivate func configureDataSourceAndDelegate() {
    if let tableView = self.tableView {
      tableView.dataSource = componentDataSource
      tableView.delegate = componentDelegate
    } else if let collectionView = self.collectionView {
      collectionView.dataSource = componentDataSource
      collectionView.delegate = componentDelegate
    }
  }

  /// Setup up the component with a given size, this is usually the parent size when used in a controller context.
  ///
  /// - Parameter size: A `CGSize` that is used to set the frame of the user interface.
  public func setup(with size: CGSize) {
    scrollView.frame.size = size

    setupHeader()
    setupFooter()

    configureDataSourceAndDelegate()

    if let tableView = self.tableView {
      setupTableView(tableView, with: size)
    } else if let collectionView = self.collectionView {
      setupCollectionView(collectionView, with: size)
    }

    layout(with: size, animated: false)
    Component.configure?(self)
  }

  /// Configure the view frame with a given size.
  ///
  /// - Parameter size: A `CGSize` used to set a new size to the user interface.
  /// - Parameter animated: Determines if the `Component` should perform animation when
  ///                       applying its new size.
  public func layout(with size: CGSize, animated: Bool = true) {
    userInterface?.layoutIfNeeded()

    if let tableView = self.tableView {
      let instance = animated ? tableView.animator() : tableView
      layoutTableView(instance, with: size)
    } else if let collectionView = self.collectionView {
      let instance = animated ? collectionView.animator() : collectionView
      layoutCollectionView(instance, with: size)
    }

    layoutHeaderFooterViews(size)

    if model.items.isEmpty, !model.layout.showEmptyComponent {
      if animated {
        view.animator().frame.size.height = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + NSAnimationContext.current().duration) { [weak self] in
          self?.view.superview?.animator().layoutSubviews()
        }
      } else {
        view.frame.size.height = 0
        view.superview?.layoutSubviews()
      }
    }
  }

  /// Setup a collection view with a specific size.
  ///
  /// - Parameters:
  ///   - collectionView: The collection view that should be configured.
  ///   - size: The size that should be used for setting up the collection view.
  fileprivate func setupCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    if let collectionViewLayout = collectionView.flowLayout {
      model.layout.configure(collectionViewLayout: collectionViewLayout)
    }

    collectionView.frame.size = size

    prepareItems()

    collectionView.backgroundColors = [NSColor.clear]
    collectionView.isSelectable = true
    collectionView.allowsMultipleSelection = false
    collectionView.allowsEmptySelection = true
    collectionView.wantsLayer = true

    let backgroundView = NSView()
    backgroundView.wantsLayer = true
    collectionView.backgroundView = backgroundView

    switch model.kind {
    case .carousel:
      setupHorizontalCollectionView(collectionView, with: size)
    default:
      break
    }
  }

  /// Set new frame to collection view and invalidate the layout.
  ///
  /// - Parameters:
  ///   - collectionView: The collection view that should be configured.
  ///   - size: The size that should be used for setting the new layout for the collection view.
  fileprivate func layoutCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    if model.kind == .carousel {
      layoutHorizontalCollectionView(collectionView, with: size)
    } else {
      layoutVerticalCollectionView(collectionView, with: size)
    }
  }

  /// Handle resizing of component when the window size changes.
  ///
  /// - Parameters:
  ///   - collectionView: The collection view instance.
  ///   - size: The new size of the parent.
  ///   - type: Determines if resizing is live or if it ended.
  fileprivate func resizeCollectionView(_ collectionView: CollectionView, with size: CGSize, type: ComponentResize) {
    if model.kind == .carousel {
      resizeHorizontalCollectionView(collectionView, with: size, type: type)
    } else {
      resizeVerticalCollectionView(collectionView, with: size, type: type)
    }
  }

  /// Register a default item as fallback, only if it is not already defined.
  ///
  /// - Parameter view: The view that should be registred as the default view.
  func registerDefaultIfNeeded(view: View.Type) {
    guard Configuration.views.storage[Configuration.views.defaultIdentifier] == nil else {
      return
    }

    Configuration.views.defaultItem = Registry.Item.classType(view)
  }

  /// This method is invoked when a double click is performed on a view.
  ///
  /// - Parameter sender: The view that was tapped.
  open func doubleMouseClick(_ sender: Any?) {
    guard let tableView = tableView,
      let item = item(at: tableView.clickedRow) else {
      return
    }

    guard model.interaction.mouseClick == .double else {
      return
    }

    delegate?.component(self, itemSelected: item)
  }

  /// This method is invoked when a single click is performed on a view.
  ///
  /// - Parameter sender: The view that was tapped.
  open func singleMouseClick(_ sender: Any?) {
    guard let tableView = tableView,
      let item = item(at: tableView.clickedRow) else {
        return
    }

    guard model.interaction.mouseClick == .single else {
      return
    }

    delegate?.component(self, itemSelected: item)
  }

  /// This method is invoked when the window is resized. It is called inside `SpotsController`.
  ///
  /// - Parameters:
  ///   - size: The new size of the parent frame.
  ///   - type: The resizing context determines if the user is currently resizing the window or
  ///           if they stopped resizing. It contains the following cases: `.live`, `.end`.
  ///           `.live` is when the user is activly resizing and `.ended` is what the name implies,
  ///           when the user stopped resizing the window and the `Component` should get its final
  ///           size.
  public func didResize(size: CGSize, type: ComponentResize) {
    if type == .end {
      reload(nil)
    } else {
      if let tableView = tableView {
        resizeTableView(tableView, with: size, type: type)
      } else if let collectionView = collectionView {
        resizeCollectionView(collectionView, with: size, type: type)
      }
    }
  }

  /// This method is invoked after mutations has been performed on a component.
  public func afterUpdate() {
    if let superview = view.superview {
      let size = CGSize(width: superview.frame.width,
                        height: view.frame.height)
      layout(with: size)
      reloadHeader()
      reloadFooter()
    }

    guard model.kind == .carousel else {
      return
    }
    scrollView.scrollingEnabled = (model.items.count > 1)
    scrollView.hasHorizontalScroller = (model.items.count > 1)
  }
}
