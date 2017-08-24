import Cocoa

public enum ControllerBackground {
  case regular, dynamic
}

open class SpotsController: NSViewController, SpotsProtocol {

  /// A closure that is called when the controller is reloaded with components
  public static var componentsDidReloadComponentModels: ((SpotsController) -> Void)?

  open static var configure: ((_ container: SpotsScrollView) -> Void)?

  /// A collection of components.
  open var components: [Component] {
    didSet {
      components.forEach { $0.delegate = delegate }
      delegate?.componentsDidChange(components)
    }
  }

  /// A manager that handles the updating logic for the current controller.
  public var manager: SpotsControllerManager = SpotsControllerManager()

  public var contentView: View {
    return view
  }

  /// An array of refresh positions to avoid refreshing multiple times when using infinite scrolling
  open var refreshPositions = [CGFloat]()

  /// An optional StateCache used for view controller caching
  open var stateCache: StateCache?

  #if DEVMODE
  /// A dispatch queue is a lightweight object to which your application submits blocks for subsequent execution.
  public let fileQueue: DispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
  /// An identifier for the type system object being monitored by a dispatch source.
  public var source: DispatchSourceFileSystemObject?
  #endif

  /// A delegate for when an item is tapped within a Spot
  weak public var delegate: ComponentDelegate? {
    didSet {
      components.forEach {
        $0.delegate = delegate
      }
      delegate?.componentsDidChange(components)
    }
  }

  /// A custom scroll view that handles the scrolling for all internal scroll views
  public var scrollView: SpotsScrollView = SpotsScrollView()

  /// A scroll delegate for handling didReachBeginning and didReachEnd
  weak open var scrollDelegate: ScrollDelegate?

  /// A bool value to indicate if the Controller is refeshing
  open var refreshing = false

  fileprivate let backgroundType: ControllerBackground

  /**
   - parameter components: An array of components.
   - parameter backgroundType: The type of background that the Controller should use, .Regular or .Dynamic
   */
  public required init(components: [Component] = [], backgroundType: ControllerBackground = .regular) {
    self.components = components
    self.backgroundType = backgroundType
    super.init(nibName: nil, bundle: nil)!

    NotificationCenter.default.addObserver(self, selector: #selector(SpotsController.scrollViewDidScroll(_:)), name: NSNotification.Name.NSScrollViewDidLiveScroll, object: scrollView)

    NotificationCenter.default.addObserver(self, selector: #selector(windowDidResize(_:)), name: NSNotification.Name.NSWindowDidResize, object: nil)

    NotificationCenter.default.addObserver(self, selector: #selector(windowDidEndLiveResize(_:)), name: NSNotification.Name.NSWindowDidEndLiveResize, object: nil)
  }

  /**
   - parameter cacheKey: A key that will be used to identify the StateCache
   */
  public convenience init(cacheKey: String) {
    let stateCache = StateCache(key: cacheKey)
    self.init(components: Parser.parse(stateCache.load()))
    self.stateCache = stateCache
  }

  /**
   - parameter component: A Component object
   */
  public convenience init(component: Component) {
    self.init(components: [component])
  }

  /**
   - parameter json: A JSON dictionary that gets parsed into UI elements
   */
  public convenience init(_ json: [String : Any]) {
    self.init(components: Parser.parse(json))
  }

  /**
   deinit
   */
  deinit {
    NotificationCenter.default.removeObserver(self)
    components.forEach { component in
      component.delegate = nil
    }
    delegate = nil
    scrollDelegate = nil
  }

  /**
   Returns an object initialized from data in a given unarchiver

   - parameter coder: An unarchiver object.
   */
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /**
   A generic look up method for resolving components using a closure

   - parameter closure: A closure to perform actions on a component

   - returns: An optional CoreComponent object
   */
  public func resolve(component closure: (_ index: Int, _ component: Component) -> Bool) -> Component? {
    for (index, component) in components.enumerated()
      where closure(index, component) {
        return component
    }
    return nil
  }

  /// Instantiates a view from a nib file and sets the value of the view property.
  open override func loadView() {
    let view: NSView

    switch backgroundType {
    case .regular:
      view = NSView()
    case .dynamic:
      let visualEffectView = NSVisualEffectView()
      visualEffectView.blendingMode = .behindWindow
      view = visualEffectView
    }

    view.autoresizingMask = .viewWidthSizable
    view.autoresizesSubviews = true
    self.view = view
  }

  /// Called after the view controller’s view has been loaded into memory.
  open override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(scrollView)
    scrollView.hasVerticalScroller = true
    scrollView.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]

    SpotsController.configure?(scrollView)
  }

  /// Called immediately after the layout() method of the view controller's view is called.
  open override func viewDidLayout() {
    super.viewDidLayout()

    for component in components {
      component.collectionView?.collectionViewLayout?.invalidateLayout()
    }

    scrollView.layoutViews(animated: false)
  }

  /// Called after the view controller’s view has been loaded into memory is about to be added to the view hierarchy in the window.
  open override func viewWillAppear() {
    super.viewWillAppear()
    setupComponents()
    scrollView.layoutViews(animated: false)
  }

  /// Called when the view controller’s view is fully transitioned onto the screen.
  open override func viewDidAppear() {
    super.viewDidAppear()
    scrollView.layoutViews(animated: false)
  }

  /// Reload controller with a new set of components.
  ///
  /// - Parameters:
  ///   - components: The new collection of components.
  ///   - closure: A completion closure that is invoked when the components are setup.
  public func reloadComponents(_ components: [Component], closure: (() -> Void)?) {
    for component in self.components {
      component.delegate = nil
      component.view.removeFromSuperview()
    }
    self.components = components
    delegate = nil

    setupComponents()
    closure?()
    scrollView.layoutSubviews()
  }

  /**
   - parameter animated: An optional animation closure that runs when a component is being rendered
   */
  public func setupComponents(animated: ((_ view: View) -> Void)? = nil) {
    components.enumerated().forEach { index, component in
      setupComponent(at: index, component: component)
      animated?(component.view)
    }
  }

  /// Setup component with size of the controller view.
  ///
  /// - Parameters:
  ///   - index: The index of the component.
  ///   - component: The component that should be setup.
  public func setupComponent(at index: Int, component: Component) {
    components[index].model.index = index
    component.setup(with: CGSize(width: view.frame.width, height: view.frame.size.height))
    component.model.size = CGSize(
      width: view.frame.width,
      height: ceil(component.view.frame.height))

    if component.view.superview == nil {
      scrollView.componentsView.addSubview(component.view)
    }

    scrollView.display()
  }

  /// Deselect all selections on all components except a specific one.
  ///
  /// - Parameter selectedComponent: The component that should excluded from deselecting.
  public func deselectAllExcept(selectedComponent: Component) {
    for component in components {
      if selectedComponent.view != component.view {
        component.deselect()
      }
    }
  }

  /// Invoked when the window that the controller belongs to is resized.
  ///
  /// - Parameter notification: A container for information broadcast through a notification center to all registered observers.
  open func windowDidResize(_ notification: Notification) {
    for component in components {
      component.didResize(size: view.frame.size, type: .live)
    }
    scrollView.layoutViews(animated: false)
  }

  /// Invoked when window has received its new size.
  ///
  /// - Parameter notification: A container for information broadcast through a notification center to all registered observers.
  public func windowDidEndLiveResize(_ notification: Notification) {
    components.forEach { component in
      component.didResize(size: view.frame.size, type: .end)
    }
    scrollView.layoutViews(animated: false)
  }

  /// Invoked when the `SpotsScrollView` scrolls.
  /// Handles calling `didReachEnd` and `didReachBeginning` on the `ScrollDelegate`.
  ///
  /// - Parameter notification: A container for information broadcast through a notification center to all registered observers.
  open func scrollViewDidScroll(_ notification: NSNotification) {
    guard let scrollView = notification.object as? SpotsScrollView,
      let delegate = scrollDelegate,
      let _ = NSApplication.shared().mainWindow
      else {
        return
    }

    if let indicatorValue = scrollView.verticalScroller?.floatValue {
      if indicatorValue > 0.9 {
        refreshing = true
        delegate.didReachEnd(in: scrollView) {
          self.refreshing = false
        }
      } else if indicatorValue < 0.1 {
        refreshing = true
        delegate.didReachBeginning(in: scrollView) {
          self.refreshing = false
        }
      }

      return
    }
  }
}
