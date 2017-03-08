import UIKit
import Cache

/// A controller powered by CoreComponent objects
open class Controller: UIViewController, SpotsProtocol, ComponentFocusDelegate, UIScrollViewDelegate {

  open var contentView: View {
    return view
  }

  public weak var focusedSpot: CoreComponent?
  public var focusedItemIndex: Int?

  /// A closure that is called when the controller is reloaded with components
  public static var componentsDidReloadComponentModels: ((Controller) -> Void)?

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

  /// A collection of CoreComponent objects.
  open var components: [CoreComponent] {
    didSet { componentsDidChange() }
  }

  /// An array of refresh positions to avoid refreshing multiple times when using infinite scrolling.
  public var refreshPositions = [CGFloat]()
  /// A bool value to indicate if the Controller is refeshing.
  public var refreshing = false
  /// A convenience method for resolving the first component.
  public var component: CoreComponent? {
    return component(at: 0, ofType: CoreComponent.self)
  }

  #if DEVMODE
  /// A dispatch queue is a lightweight object to which your application submits blocks for subsequent execution.
  public let fileQueue: DispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
  /// An identifier for the type system object being monitored by a dispatch source.
  public var source: DispatchSourceFileSystemObject?
  #endif

  /// An optional StateCache used for view controller caching.
  public var stateCache: StateCache?

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
  open var scrollView: SpotsScrollView = SpotsScrollView()

  #if os(iOS)
  /// A UIRefresh control.
  /// Note: Only available on iOS.
  public lazy private(set) var refreshControl = UIRefreshControl()
  #endif

  // MARK: Initializer

  /// A required initializer for initializing a controller with CoreComponent objects
  ///
  /// - parameter components: A collection of CoreComponent objects that should be setup and be added to the view hierarchy.
  ///
  /// - returns: An initalized controller.
  public required init(components: [CoreComponent] = []) {
    self.components = components
    super.init(nibName: nil, bundle: nil)

    let notificationName = NSNotification.Name(rawValue: NotificationKeys.deviceDidRotateNotification.rawValue)
    NotificationCenter.default.addObserver(self,
                                           selector:#selector(self.deviceDidRotate(_:)),
                                           name: notificationName,
                                           object: nil)
  }

  /// Initialize a new controller with a single component
  ///
  /// - parameter component: A CoreComponent object
  ///
  /// - returns: An initialized controller containing one object.
  public convenience init(component: CoreComponent) {
    self.init(components: [component])
  }

  /// Initialize a new controller using JSON.
  ///
  /// - parameter json: A JSON dictionary that gets parsed into UI elements.
  ///
  /// - returns: An initialized controller with CoreComponent objects built from JSON.
  public convenience init(_ json: [String : Any]) {
    self.init(components: Parser.parse(json))
  }

  /// Initialize a new controller with a cache key.
  ///
  /// - parameter cacheKey: A key that will be used to identify the StateCache.
  ///
  /// - returns: An initialized controller with a cache.
  public convenience init(cacheKey: String) {
    let stateCache = StateCache(key: cacheKey)
    self.init(components: Parser.parse(stateCache.load()))
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

  ///  A generic look up method for resolving components based on index
  ///
  /// - parameter index: The index of the component that you are trying to resolve.
  /// - parameter type: The generic type for the component you are trying to resolve.
  ///
  /// - returns: An optional CoreComponent object of inferred type.
  open func component<T>(at index: Int = 0, ofType type: T.Type) -> T? {
    return components.filter({ $0.index == index }).first as? T
  }

  /// A look up method for resolving a component at index as a CoreComponent object.
  ///
  /// - parameter index: The index of the component that you are trying to resolve.
  ///
  /// - returns: An optional CoreComponent object.
  open func component(at index: Int = 0) -> CoreComponent? {
    return components.filter({ $0.index == index }).first
  }

  /// A generic look up method for resolving components using a closure
  ///
  /// - parameter closure: A closure to perform actions on a component.
  ///
  /// - returns: An optional CoreComponent object
  open func resolve(component closure: (_ index: Int, _ component: CoreComponent) -> Bool) -> CoreComponent? {
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
  func deviceDidRotate(_ notification: Notification) {
    if let userInfo = (notification as NSNotification).userInfo as? [String : Any],
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

    setupComponents()

    Controller.configure?(scrollView)
  }

  /// Notifies the component controller that its view is about to be added to a view hierarchy.
  ///
  /// - parameter animated: If true, the view is being added to the window using an animation.
  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if let tabBarController = self.tabBarController, tabBarController.tabBar.isTranslucent {
      scrollView.contentInset.bottom = tabBarController.tabBar.frame.size.height
      scrollView.scrollIndicatorInsets.bottom = scrollView.contentInset.bottom
    }

    #if os(iOS)
      refreshControl.addTarget(self, action: #selector(refreshComponent(_:)), for: .valueChanged)

      guard let _ = refreshDelegate, refreshControl.superview == nil
        else { return }
      scrollView.insertSubview(refreshControl, at: 0)
    #endif
  }

  /// Configure scrollview and composite views with new size.
  ///
  /// - parameter size: The size that should be used to configure the views.
  func configure(withSize size: CGSize) {
    scrollView.frame.size = size
    scrollView.componentsContentView.frame.size = size

    components.forEach { component in
      component.layout(size)

      component.compositeComponents.forEach {
        $0.component.layout(component.view.frame.size)
      }
    }
  }

  /// Notifies the container that the size of tis view is about to change.
  ///
  /// - parameter size:        The new size for the container’s view.
  /// - parameter coordinator: The transition coordinator object managing the size change. You can use this object to animate your changes or get information about the transition that is in progress.
  open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)

    #if os(iOS)
      guard components_shouldAutorotate() else { return }
    #endif

    coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
      self.configure(withSize: size)
    }) { (UIViewControllerTransitionCoordinatorContext) in
      self.configure(withSize: size)
      NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKeys.deviceDidRotateNotification.rawValue),
                                      object: nil,
                                      userInfo: ["size": RotationSize(size: size)])
    }
  }

  /// Set up CoreComponent objects.
  ///
  /// - parameter animated: An optional animation closure that is invoked when setting up the component.
  open func setupComponents(animated: ((_ view: UIView) -> Void)? = nil) {
    var yOffset: CGFloat = 0.0

    components.enumerated().forEach { index, component in
      setupComponent(at: index, component: component)
      animated?(component.view)
      (component as? CarouselComponent)?.layout.yOffset = yOffset
      yOffset += component.view.frame.size.height
    }
  }

  /// Set up Spot at index
  ///
  /// - parameter index: The index of the CoreComponent object
  /// - parameter component:  The component that is going to be setup
  open func setupComponent(at index: Int, component: CoreComponent) {
    if component.view.superview == nil {
      scrollView.componentsContentView.addSubview(component.view)
    }

    guard let superview = component.view.superview else {
      return
    }

    component.view.frame.origin.x = 0.0
    component.model.index = index
    component.setup(superview.frame.size)
    component.model.size = CGSize(
      width: superview.frame.width,
      height: ceil(component.view.frame.height))
    component.focusDelegate = self

    /// Spot handles registering and preparing the items internally so there is no need to run this for that class.
    /// This should be removed in the future when we decide to remove the core types.
    if !(component is Component) {
      component.registerAndPrepare()

      if !component.items.isEmpty {
        component.view.layoutIfNeeded()
      }
    }
  }

  #if os(iOS)
  /// Refresh action for UIRefreshControl
  ///
  /// - parameter refreshControl: The refresh control used to refresh the controller.
  open func refreshComponent(_ refreshControl: UIRefreshControl) {
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
extension Controller {

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
  fileprivate  func updateDelegates() {
    components.forEach {
      $0.delegate = delegate
      $0.focusDelegate = self

      $0.compositeComponents.forEach {
        $0.component.delegate = delegate
        $0.component.focusDelegate = self
      }
    }
  }

  /// Resolve component at index path.
  ///
  /// - parameter indexPath: The index path of the component belonging to the CoreComponent object at that index.
  ///
  /// - returns: A ComponentModel object at index path.
  fileprivate func component(at indexPath: IndexPath) -> ComponentModel {
    return component(at: indexPath).model
  }

  /// Resolve component at index path.
  ///
  /// - parameter indexPath: The index path of The component.
  ///
  /// - returns: A CoreComponent object.
  fileprivate func component(at indexPath: IndexPath) -> CoreComponent {
    return components[indexPath.item]
  }
}
