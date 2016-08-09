import Spots
import Brick
import Compass
import Malibu
import Sugar
import Tailor

public enum KeyboardEvents: UInt16 {
  case Up = 126
  case Down = 125
  case Enter = 36
}

class DetailController: SpotsController, SpotsDelegate, SpotsScrollDelegate {

  lazy var shadowSeparator = NSView().then {
    $0.alphaValue = 0.0
    $0.frame.size.height = 2
    $0.wantsLayer = true
    $0.layer?.backgroundColor = NSColor.blackColor().alpha(0.4).CGColor

    var gradientLayer = CAGradientLayer()
    gradientLayer.frame.size.height = $0.frame.size.height
    gradientLayer.colors = [
      NSColor.clearColor().CGColor,
      NSColor.blackColor().CGColor,
      NSColor.clearColor().CGColor
    ]
    gradientLayer.locations = [0.0, 0.5, 1.0]
    gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
    gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)

    $0.layer?.mask = gradientLayer

    let shadow = NSShadow()
    shadow.shadowColor = NSColor.blackColor()
    shadow.shadowBlurRadius = 3.0
    shadow.shadowOffset = CGSize(width: 0, height: -6)
    $0.shadow = shadow
  }

  var rides = [Ride]()
  var blueprint: Blueprint? {
    didSet {
      guard let blueprint = blueprint else { return }

      #if DEVMODE
      self.source = nil
      #endif
      let newCache = SpotCache(key: blueprint.cacheKey)
      self.stateCache = newCache
      var spots = newCache.load()

      if spots.isEmpty {
        spots = blueprint.template
      }

      reloadSpots(Parser.parse(spots)) {
        self.process(self.fragments)
        self.build(blueprint)
        self.spotsDelegate = self
        self.cache()
      }
    }
  }

  var fragments: [String : AnyObject] = [:]

  required init(spots: [Spotable], backgroundType: SpotsControllerBackground) {
    super.init(spots: spots, backgroundType: backgroundType)

    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DetailController.willEnterFullscreen(_:)), name: NSWindowWillEnterFullScreenNotification, object: nil)

    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DetailController.willExitFullscreen(_:)), name: NSWindowWillExitFullScreenNotification, object: nil)

    let notificationCenter = NSNotificationCenter.defaultCenter()
    notificationCenter.addObserver(self, selector: #selector(DetailController.activate),
                                   name: "sessionActivate", object: nil)

    NSEvent.addLocalMonitorForEventsMatchingMask(.KeyDownMask) { (theEvent) -> NSEvent? in
      if self.handleKeyDown(theEvent) == true {
        return theEvent
      }
      return nil
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(shadowSeparator)
    spotsScrollView.frame.origin.y = -40
  }

  override func viewWillAppear() {
    super.viewWillAppear()
    guard let blueprint = blueprint else { return }
    build(blueprint)
    spotsScrollDelegate = self
  }

  func willEnterFullscreen(notification: NSNotification) {
    self.spotsScrollView.animator().setFrameOrigin(
      NSPoint(x: self.spotsScrollView.frame.origin.x, y: -20)
    )
  }

  func willExitFullscreen(notification: NSNotification) {
    spotsScrollView.frame.origin.y = -40
  }

  func build(blueprint: Blueprint) {
    removeGradientSublayers()
    shadowSeparator.alphaValue = 0.0
    for ride in rides {
      ride.cancel()
    }
    rides = []

    for element in blueprint.requests {
      guard let request = element.request else { return }
      let ride = Malibu.networking("api").GET(request)
      ride.validate()
        .toJSONDictionary()
        .done { json in
          var items: JSONArray
          if let rootElementItems: JSONArray = json.resolve(keyPath: "\(element.rootKey).items") {
            items = rootElementItems
          } else {
            if let rootItems: JSONArray = json.resolve(keyPath: "items") {
              items = rootItems
            } else {
              guard let secondaryItems: JSONArray = json.resolve(keyPath: element.rootKey) else { return }
              items = secondaryItems
            }
          }

          let viewModels = element.adapter(json: items)
          self.updateIfNeeded(spotAtIndex: element.spotIndex, items: viewModels) {
            self.cache()
          }
        }.fail { error in
          NSLog("request: \(request.message)")
          NSLog("error: \(error)")
      }
      rides.append(ride)
    }
  }

  func process(fragments: [String : AnyObject]? = nil) {
    guard let handler = blueprint?.fragmentHandler, fragments = fragments where fragments["skipHistory"] == nil else { return }

    handler(fragments: fragments, controller: self)
  }

  func removeGradientSublayers() {
    guard let sublayers = view.layer?.sublayers else { return }
    for case let sublayer as CAGradientLayer in sublayers {
      sublayer.removeFromSuperlayer()
    }
  }

  override func viewWillLayout() {
    super.viewWillLayout()

    CATransaction.begin()
    CATransaction.setDisableActions(true)

    shadowSeparator.frame.size.width = view.frame.width
    shadowSeparator.frame.origin.y = view.frame.maxY + spotsScrollView.frame.origin.y - shadowSeparator.frame.size.height

    guard let sublayers = view.layer?.sublayers else { return }
    for case let sublayer as CAGradientLayer in sublayers {
      sublayer.frame = view.frame
    }

    shadowSeparator.layer?.mask?.frame.size.width = view.frame.width

    CATransaction.commit()
  }

  override func scrollViewDidScroll(notification: NSNotification) {
    super.scrollViewDidScroll(notification)

    guard let scrollView = notification.object as? SpotsScrollView else { return }

    var from: CGFloat = 0.0
    var to: CGFloat = 0.0
    var shouldAnimate = false

    if scrollView.contentOffset.y > 0.0 && shadowSeparator.alphaValue == 0.0 {
      from = 0.0
      to = 1.0
      shouldAnimate = true
    } else if scrollView.contentOffset.y <= 0.0 && shadowSeparator.alphaValue == 1.0 {
      from = 1.0
      to = 0.0
      shouldAnimate = true
    }

    if shouldAnimate {
      NSAnimationContext.runAnimationGroup({ context in
        context.duration = 3.0
        self.shadowSeparator.alphaValue = from
      }) {
        self.shadowSeparator.alphaValue = to
      }
    }
  }

  func handleKeyDown(theEvent: NSEvent) -> Bool {
    super.keyDown(theEvent)

    guard let window = theEvent.window,
      tableView = window.firstResponder as? NSTableView,
      scrollView = tableView.superview?.superview as? NoScrollView,
      keyEvent = KeyboardEvents(rawValue: theEvent.keyCode),
      currentSpot = spots.filter({ $0.responder == tableView }).first as? Listable
      else { return true }

    if let model = currentSpot.item(tableView.selectedRow) where keyEvent == .Enter {
      spotDidSelectItem(currentSpot, item: model)
      return false
    }

    let viewRect = tableView.rectOfRow(tableView.selectedRow)
    let currentView = viewRect.origin.y + viewRect.size.height
    let viewPortMin = spotsScrollView.contentOffset.y - scrollView.frame.origin.y
    let viewPortMax = spotsScrollView.frame.size.height + spotsScrollView.contentOffset.y - scrollView.frame.origin.y - scrollView.contentInsets.top + spotsScrollView.frame.origin.y

    var newY: CGFloat = 0.0
    var shouldScroll: Bool = false
    if currentView >= viewPortMax {
      newY = viewRect.origin.y - viewRect.size.height - scrollView.frame.origin.y - scrollView.contentInsets.top
      shouldScroll = true
    } else if currentView <= viewPortMin && viewPortMin > 0.0 {
      shouldScroll = true
      newY = viewRect.origin.y - scrollView.frame.origin.y
    }

    if shouldScroll {
      NSAnimationContext.runAnimationGroup({ (context) in
        context.duration = 0.3
        var newOrigin: NSPoint = self.spotsScrollView.contentView.bounds.origin
        newOrigin.y = newY
        self.spotsScrollView.contentView.animator().setBoundsOrigin(newOrigin)
        self.spotsScrollView.reflectScrolledClipView(self.spotsScrollView.contentView)
        }, completionHandler: nil)
    }

    return true
  }

  func activate() {
    guard let blueprint = blueprint else { return }
    build(blueprint)
  }
}

extension DetailController {

  func spotDidSelectItem(spot: Spotable, item: ViewModel) {
    guard let action = item.action else { return }

    if item.kind == "track" {
      for item in spot.items where item.meta("playing", type: Bool.self) == true {
        var item = item
        item.meta["playing"] = false
        update(item, index: item.index, spotIndex: spot.index, withAnimation: .None, completion: nil)
      }
      var newItem = item
      newItem.meta["playing"] = !item.meta("playing", false)

      update(newItem, index: item.index, spotIndex: spot.index, withAnimation: .None, completion: nil)

      if item.meta("playing", type: Bool.self) == true {
        guard let appDelegate = NSApplication.sharedApplication().delegate as? AppDelegate else { return }
        appDelegate.player?.stop()
        return
      }
    }

    AppDelegate.navigate(action, fragments: item.meta("fragments", [:]))
  }
}

extension DetailController {

  func spotDidReachBeginning(completion: Completion) {
    completion?()
  }

  func spotDidReachEnd(completion: Completion) {
    completion?()
  }
}
