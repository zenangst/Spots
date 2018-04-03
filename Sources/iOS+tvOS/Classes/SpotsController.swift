import UIKit
import Cache

/// A controller powered by components.
open class SpotsController: UIViewController, SpotsProtocol, ComponentFocusDelegate, UIScrollViewDelegate {
  open var contentView: View {
    return view
  }

  public var focusedItemIndex: Int?
  /// The instance of the current focused component.
  /// This property is observable using Key-value observing.
  @objc dynamic public weak var focusedComponent: Component?
  /// The view instance of the current focused view.
  /// This property is observable using Key-value observing.
  @objc dynamic public weak var focusedView: View?

  /// A closure that is called when the controller is reloaded with components
  public static var componentsDidReloadComponentModels: ((SpotsController) -> Void)?

  /// A notification enum
  ///
  /// - deviceDidRotateNotification: Used when the device is rotated
  private enum NotificationKeys: String {
    /// A notification key for when the device did rotate
    case deviceDidRotateNotification
  }

  /// A rotation class that is used in the `deviceDidRotate` notification
  private class RotationSize {
    /// The new size after rotating.
    let size: CGSize

    /// Initialize a new size when rotating
    ///
    /// - Parameter size: A CGSize with the new size after rotating the device.
    init(size: CGSize) {
      self.size = size
    }
  }

  /// A static closure to configure SpotsScrollView.
  open static var configure: ((_ container: SpotsScrollView) -> Void)?

  /// Initial content offset for Controller, defaults to UIEdgeInsetsZero.
  open fileprivate(set) var initialInset: UIEdgeInsets = UIEdgeInsets.zero

  /// A manager that handles the updating logic for the current controller.
  public var manager: SpotsControllerManager = SpotsControllerManager()

  /// A collection of components.
  open var components: [Component] {
    didSet { componentsDidChange() }
  }

  /// An array of refresh positions to avoid refreshing multiple times when using infinite scrolling.
  public var refreshPositions = [CGFloat]()
  /// A bool value to indicate if the Controller is refeshing.
  public var refreshing = false

  /// A convenience method for resolving the first component.
  public var component: Component? {
    return component(at: 0)
  }

  #if DEVMODE
  /// A dispatch queue is a lightweight object to which your application submits blocks for subsequent execution.
  public let fileQueue: DispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
  /// An identifier for the type system object being monitored by a dispatch source.
  public var source: DispatchSourceFileSystemObject?
  #endif

  /// An optional StateCache used for view controller caching.
  public var stateCache: StateCache?

  #if os(tvOS)
  let focusManager: FocusEngineManager = .init()

  /// A default focus guide that is constrained to the controllers
  public lazy var focusGuide: UIFocusGuide = {
    let focusGuide = UIFocusGuide()
    focusGuide.isEnabled = false
    return focusGuide
  }()
  #endif

  /// A delegate for when an item is tapped within a Spot.
  weak open var delegate: ComponentDelegate? {
    didSet { componentsDelegateDidChange() }
  }

  #if os(iOS)
  /// A refresh delegate for handling reloading of a Spot.
  weak public var refreshDelegate: RefreshDelegate? {
    didSet {
      refreshControl.isHidden = refreshDelegate == nil
    }
  }
  #endif

  /// A scroll delegate for handling didReachBeginning and didReachEnd.
  weak public var scrollDelegate: ScrollDelegate?

  /// A custom scroll view that handles the scrolling for all internal scroll views.
  open var scrollView: SpotsScrollView

  #if os(iOS)
  /// A UIRefresh control.
  /// Note: Only available on iOS.
  open lazy private(set) var refreshControl: UIRefreshControl = SpotsRefreshControl()
  #endif

  let configuration: Configuration

  // MARK: Initializer

  /// A required initializer for initializing a controller with components.
  ///
  /// - parameter components: A collection of components. that should be setup and be added to the view hierarchy.
  ///
  /// - returns: An initalized controller.
  public required init(components: [Component] = [], configuration: Configuration = .shared) {
    self.components = components
    self.configuration = configuration
    self.scrollView = SpotsScrollView(frame: .zero, configuration: configuration)
    super.init(nibName: nil, bundle: nil)

    let notificationName = NSNotification.Name(rawValue: NotificationKeys.deviceDidRotateNotification.rawValue)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(self.deviceDidRotate(_:)),
                                           name: notificationName,
                                           object: nil)
  }

  /// Initialize a new controller with a single component
  ///
  /// - parameter component: A Component object
  ///
  /// - returns: An initialized controller containing one object.
  public convenience init(component: Component, configuration: Configuration = .shared) {
    self.init(components: [component], configuration: configuration)
  }

  /// Initialize a new controller using JSON.
  ///
  /// - parameter json: A JSON dictionary that gets parsed into UI elements.
  ///
  /// - returns: An initialized controller with components. built from JSON.
  @available(*, deprecated: 7.0, message: "Deprecated in favor for init with data")
  public convenience init(_ json: [String: Any], configuration: Configuration = .shared) {
    self.init(components: Parser.parseComponents(json: json, configuration: configuration),
              configuration: configuration)
  }

  /// Initialize a new controller using JSON data.
  ///
  /// - parameter json: A JSON data that gets parsed into UI elements.
  ///
  /// - returns: An initialized controller with components. built from JSON.
  public convenience init(_ data: Data, configuration: Configuration = .shared) {
    self.init(components: Parser.parseComponents(data: data, configuration: configuration),
              configuration: configuration)
  }

  /// Initialize a new controller with a cache key.
  ///
  /// - parameter cacheKey: A key that will be used to identify the StateCache.
  ///
  /// - returns: An initialized controller with a cache.
  public convenience init(cacheKey: String, configuration: Configuration = .shared) {
    let stateCache = StateCache(key: cacheKey)
    let modelsDictionary: [String: [ComponentModel]] = stateCache.load() ?? [:]

    self.init(
      components: Parser.parseComponents(modelsDictionary: modelsDictionary, configuration: configuration),
      configuration: configuration
    )
    self.stateCache = stateCache
  }

  /// Init with coder.
  ///
  /// - parameter aDecoder: An NSCoder
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    #if DEVMODE
      if let source = source {
        source.cancel()
      }
      NotificationCenter.default.removeObserver(self)
    #endif

    // http://stackoverflow.com/questions/3686803/uiscrollview-exc-bad-access-crash-in-ios-sdk
    scrollView.delegate = nil
  }

  /// A generic look up method for resolving components using a closure
  ///
  /// - parameter closure: A closure to perform actions on a component.
  ///
  /// - returns: An optional Component object
  open func resolve(component closure: (_ index: Int, _ component: Component) -> Bool) -> Component? {
    for (index, component) in components.enumerated()
      where closure(index, component) {
        return component
    }
    return nil
  }

  // MARK: - Notifications

  /// Handle rotation for views that are not on screen.
  ///
  /// - parameter notification: A notification containing the new size.
  @objc func deviceDidRotate(_ notification: Notification) {
    /// This will rotate views that are not visisble on screen.
    if let userInfo = (notification as NSNotification).userInfo as? [String: Any],
      let rotationSize = userInfo["size"] as? RotationSize, view.window == nil {
      configure(withSize: rotationSize.size)
    }
  }

  // MARK: - View Life Cycle

  /// Called after the component controller's view is loaded into memory.
  open override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(scrollView)
    scrollView.frame = view.bounds
    scrollView.alwaysBounceVertical = true
    scrollView.clipsToBounds = true
    scrollView.delegate = self

    #if os(tvOS)
      configure(focusGuide: focusGuide, for: scrollView, enabled: false)
    #endif
    setupComponents()
    SpotsController.configure?(scrollView)
  }

  /// Notifies the component controller that its view is about to be added to a view hierarchy.
  ///
  /// - parameter animated: If true, the view is being added to the window using an animation.
  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    #if os(iOS)
      if let tabBarController = self.tabBarController, tabBarController.tabBar.isTranslucent {
        scrollView.contentInset.bottom = tabBarController.tabBar.frame.size.height
        scrollView.scrollIndicatorInsets.bottom = scrollView.contentInset.bottom
      }

      refreshControl.addTarget(self, action: #selector(refreshComponent(_:)), for: .valueChanged)

      guard refreshDelegate != nil, refreshControl.superview == nil else {
        return
      }
      scrollView.insertSubview(refreshControl, at: 0)
    #endif
  }

  /// Configure scrollview with new size.
  ///
  /// - parameter size: The size that should be used to configure the views.
  func configure(withSize size: CGSize) {
    components.forEach { component in
      component.view.frame.size = size
      component.prepareItems()
      component.collectionView?.flowLayout?.prepare()
      component.collectionView?.flowLayout?.invalidateLayout()
      component.collectionView?.flowLayout?.finalizeAnimatedBoundsChange()
      component.headerView?.frame.size.width = size.width
      component.footerView?.frame.size.width = size.width
      component.headerView?.frame.origin = .zero
      component.footerView?.frame.origin = .zero
    }

    scrollView.frame.size = size
    scrollView.componentsView.frame.size = size
  }

  open override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    scrollView.frame = view.bounds
    scrollView.componentsView.frame = scrollView.bounds
  }

  /// Notifies the container that the size of tis view is about to change.
  ///
  /// - parameter size:        The new size for the container’s view.
  /// - parameter coordinator: The transition coordinator object managing the size change. You can use this object to animate your changes or get information about the transition that is in progress.
  open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)

    #if os(iOS)
      guard components_shouldAutorotate() else {
        return
      }
    #endif

    let completion: (UIViewControllerTransitionCoordinatorContext) -> Void = { [weak self] _ in
      guard let strongSelf = self else {
        return
      }

      strongSelf.scrollView.isRotating = false

      for component in strongSelf.components where component.model.interaction.paginate != .disabled {
        component.setupInfiniteScrolling()
      }

      NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKeys.deviceDidRotateNotification.rawValue),
                                      object: nil,
                                      userInfo: ["size": RotationSize(size: size)])
    }

    scrollView.isRotating = true
    coordinator.animate(alongsideTransition: { [weak self] _ in
      self?.configure(withSize: size)
      }, completion: completion)
  }

  /// Set up components.
  ///
  /// - parameter animated: An optional animation closure that is invoked when setting up the component.
  open func setupComponents(animated: ((_ view: UIView) -> Void)? = nil) {
    for (index, component) in components.enumerated() {
      setupComponent(at: index, component: component)
      animated?(component.view)
    }
    manager.purgeCachedViews(in: components)
  }

  /// Set up Spot at index
  ///
  /// - parameter index: The index of the Component object
  /// - parameter component:  The component that is going to be setup
  open func setupComponent(at index: Int, component: Component) {
    if component.view.superview == nil {
      scrollView.componentsView.addSubview(component.view)
    }

    guard let superview = component.view.superview else {
      return
    }

    component.view.frame.origin.x = 0.0
    component.model.index = index
    component.setup(with: superview.frame.size)
    component.model.size = CGSize(
      width: superview.frame.width,
      height: ceil(component.view.frame.height))
    component.focusDelegate = self
    component.delegate = delegate
  }

  #if os(iOS)
  /// Refresh action for UIRefreshControl
  ///
  /// - parameter refreshControl: The refresh control used to refresh the controller.
  @objc open func refreshComponent(_ refreshControl: UIRefreshControl) {
    Dispatch.main { [weak self] in
      guard let strongSelf = self else {
        return
      }
      strongSelf.refreshPositions.removeAll()
      strongSelf.refreshDelegate?.componentsDidReload(strongSelf.components, refreshControl: refreshControl) {
        refreshControl.endRefreshing()
      }
    }
  }
  #endif
}

// MARK: - Private methods

/// An extension with private methods on Controller
extension SpotsController {

  /// This method is triggered in `delegate.didSet`
  fileprivate func componentsDelegateDidChange() {
    updateDelegates()
  }

  /// This method is triggered in `components.didSet{}`
  fileprivate  func componentsDidChange() {
    updateDelegates()
    delegate?.componentsDidChange(components)
  }

  /// It updates the delegates for all underlaying components inside the controller.
  fileprivate func updateDelegates() {
    components.forEach {
      $0.delegate = delegate
      $0.focusDelegate = self
    }

    if focusedComponent == nil && focusedItemIndex == nil {
      focusedComponent = components.first
      focusedItemIndex = 0
    }
  }

  /// Resolve component at index path.
  ///
  /// - parameter indexPath: The index path of the component belonging to the Component object at that index.
  ///
  /// - returns: A ComponentModel object at index path.
  fileprivate func component(at indexPath: IndexPath) -> ComponentModel {
    return component(at: indexPath).model
  }

  /// Resolve component at index path.
  ///
  /// - parameter indexPath: The index path of The component.
  ///
  /// - returns: A component.
  fileprivate func component(at indexPath: IndexPath) -> Component {
    return components[indexPath.item]
  }
}
