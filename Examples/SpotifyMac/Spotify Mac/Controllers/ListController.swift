import Cocoa
import Spots
import Brick
import Malibu
import Sugar
import Compass
import Sugar

class ListController: Controller, SpotsDelegate, SpotsScrollDelegate {

  struct UI {
    static let main = 0
    static let yourMusic = 1
    static let playlists = 2
  }

  lazy var shadowSeparator = NSView().then {
    $0.alphaValue = 0.0
    $0.frame.size.height = 1
    $0.wantsLayer = true
    $0.layer?.backgroundColor = NSColor.lightGray.alpha(0.4).cgColor

    var gradientLayer = CAGradientLayer()
    gradientLayer.frame.size.height = $0.frame.size.height
    gradientLayer.colors = [
      NSColor.clear.cgColor,
      NSColor.black.cgColor,
      NSColor.clear.cgColor
    ]
    gradientLayer.locations = [0.0, 0.5, 1.0]
    gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
    gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)

    $0.layer?.mask = gradientLayer

    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black
    shadow.shadowBlurRadius = 3.0
    shadow.shadowOffset = CGSize(width: 0, height: -6)
    $0.shadow = shadow
  }

  var selectedIndex: Int = 0

  convenience init(cacheKey: String) {
    let stateCache = SpotCache(key: cacheKey)
    var spots = stateCache.load()

    if spots.isEmpty {
    let size = ["height" : 40.0]
      let meta = ["separator" : false, "tintColor" : "37D247"] as [String : Any]
      let mainItems: [[String : Any]] = [
        [
          "title" : "Browse",
          "subtitle" : "",
          "action" : "browse",
          "image" : "iconBrowse",
          "kind" : "list",
          "size" : size,
          "meta": meta
        ],
        [
          "title" : "Following",
          "action" : "following",
          "image" : "iconActivity",
          "kind" : "list",
          "size" : size,
          "meta": meta
        ],
        [
          "title" : "Top Artists",
          "image" : "topArtists",
          "action" : "topArtists",
          "kind" : "list",
          "size" : size,
          "meta": meta
        ],
        [
          "title" : "Top Tracks",
          "image" : "topTracks",
          "action" : "topTracks",
          "kind" : "list",
          "size" : size,
          "meta": meta
        ]
      ]
      let yourMusicItems: [[String : Any]] = [
        [
          "title" : "Songs",
          "action" : "songs",
          "image" : "iconSongs",
          "kind" : "list",
          "size" : size,
          "meta": meta
        ],
        [
          "title" : "Albums",
          "action" : "albums",
          "image" : "iconAlbums",
          "kind" : "list",
          "size" : size,
          "meta": meta
        ],
        [
          "title" : "Playlists",
          "action" : "playlists",
          "image" : "iconAlbums",
          "kind" : "list",
          "size" : size,
          "meta": meta
        ]
      ]

      spots = [
        "components" : [
          [
            "kind" : "list",
            "span" : 1,
            "items" : mainItems,
            "meta" : [
              ListSpot.Key.titleSeparator : false,
              "titleFontSize" : 11,
              "insetTop" : 0,
              "insetLeft" : 0,
              "insetRight" : 0,
              "titleLeftInset" : 8.0
            ]
          ],
          [
            "title" : "Your Music".uppercased(),
            "kind" : "list",
            "span" : 1,
            "items" : yourMusicItems,
            "meta" : [
              ListSpot.Key.titleSeparator : false,
              "titleFontSize" : 11,
              "insetTop" : 0.0,
              "insetLeft" : 0,
              "insetRight" : 0,
              "titleLeftInset" : 8.0
            ]
          ],
          [
            "title" : "Playlists".uppercased(),
            "kind" : "list",
            "span" : 1,
            "meta" : [
              ListSpot.Key.titleSeparator : false,
              "titleFontSize" : 11,
              "insetTop" : 0.0,
              "insetLeft" : 0,
              "insetRight" : 0,
              "titleLeftInset" : 8.0
            ]
          ]
        ]
      ]
    }

    self.init(spots: Parser.parse(spots), backgroundType: .dynamic)

    self.stateCache = stateCache
    self.delegate = self
    self.scrollDelegate = self
    spotsScrollView.frame.origin.y = -40

    NotificationCenter.default.addObserver(self, selector: #selector(ListController.willFullscreen(_:)), name: NSNotification.Name.NSWindowWillEnterFullScreen, object: nil)

    NotificationCenter.default.addObserver(self, selector: #selector(ListController.willExitFullscreen(_:)), name: NSNotification.Name.NSWindowWillExitFullScreen, object: nil)

    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(self, selector: #selector(ListController.activate),
                                   name: NSNotification.Name(rawValue: "sessionActivate"), object: nil)

    NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (theEvent) -> NSEvent? in
      self.keyDown(with: theEvent)
      return theEvent
    }
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.wantsLayer = true
    (view as? NSVisualEffectView)?.material = .ultraDark

    view.addSubview(shadowSeparator)
  }

  override func viewDidAppear() {
    super.viewDidAppear()

    fetchPlaylists()

    guard let appDelegate = NSApplication.shared().delegate as? AppDelegate,
      let window = appDelegate.window,
      let firstSpot = spot(at: 0, Listable.self) else {
      return
    }

    firstSpot.selectFirst()
    window.makeFirstResponder(firstSpot.responder)
  }

  override func viewWillLayout() {
    super.viewWillLayout()

    CATransaction.begin()
    CATransaction.setDisableActions(true)

    shadowSeparator.frame.size.width = view.frame.width
    shadowSeparator.frame.origin.y = view.frame.maxY + spotsScrollView.frame.origin.y - shadowSeparator.frame.size.height
    shadowSeparator.layer?.mask?.frame.size.width = view.frame.width

    CATransaction.commit()
  }

  func willFullscreen(_ notification: Notification) {
    self.spotsScrollView.animator().setFrameOrigin(
      NSPoint(x: self.spotsScrollView.frame.origin.x, y: 0)
    )
  }

  func willExitFullscreen(_ notification: Notification) {
    spotsScrollView.frame.origin.y = -40
  }

  override func scrollViewDidScroll(_ notification: NSNotification) {
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

  override func keyDown(with theEvent: NSEvent) {
    super.keyDown(with: theEvent)

    guard let appDelegate = NSApplication.shared().delegate as? AppDelegate,
      let window = appDelegate.window,
      let keyEvent = KeyboardEvents(rawValue: theEvent.keyCode),
      let tableView = window.firstResponder as? NSTableView,
      let scrollView = tableView.superview?.superview as? ScrollView,
      let currentSpot = spots.filter({ $0.responder == tableView }).first as? Listable
      else { return }

    var newIndex: Int?
    if keyEvent == .down && currentSpot.component.items.count - 1 == tableView.selectedRow {
      newIndex = currentSpot.index + 1
    } else if keyEvent == .up && tableView.selectedRow == 0 {
      newIndex = currentSpot.index - 1
    }

    if let newIndex = newIndex, let newSpot = spot(at: newIndex, Listable.self) {
      window.makeFirstResponder(newSpot.responder)
    }

    let viewRect = tableView.rect(ofRow: tableView.selectedRow)
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
  }

  func activate() {
    fetchPlaylists()
  }

  func fetchPlaylists() {
    Malibu.networking("api").GET(PlaylistsRequest())
      .validate()
      .toJsonDictionary()
      .done { json in
        guard let items = json["items"] as? [[String : Any]] else { return }
        let viewModels = self.parse(items)
        self.updateIfNeeded(spotAtIndex: UI.playlists, items: viewModels) {
          self.cache()
        }
    }
  }

  fileprivate func parse(_ json: [[String : Any]]) -> [Item] {
    var viewModels = [Item]()
    for item in json {
      let owner = (item["owner"] as? JSONDictionary)?["id"] as? String ?? ""
      let playlistID = item["id"] as? String ?? ""
      var description = ""
      description = "by \(item.resolve(keyPath: "owner.id") ?? "")\n"
      description += "Collaborative: \((item["collaborative"] as? Bool) == true ? "Yes" : "No")\n"
      description += "Public: \((item["collaborative"] as? Bool) == true ? "Yes" : "No")\n"
      if let tracks: Int = item.resolve(keyPath: "tracks.total") {
        description += "Tracks: \(tracks)\n"
      }

      let viewModel = Item(
        title: item["name"] as? String ?? "",
        image: "iconMyMusic",
        kind: "list",
        action: "playlist:\(owner):\(playlistID)",
        size: CGSize(width: 120, height: 40),
        meta: [
          "separator" : false,
          "tintColor" : "37D247",
          "fragments" : [
            "title" : item.resolve(keyPath: "name") ?? "",
            "image" : item.resolve(keyPath: "images.0.url") ?? "",
            "description" : description
          ]
        ]
      )

      viewModels.append(viewModel)
    }

    return viewModels
  }
}

extension ListController {

  func spotDidSelectItem(_ spot: Spotable, item: Item) {
    deselectAllExcept(selectedSpot: spot)

    guard let action = item.action else { return }

    AppDelegate.navigate(action, fragments: item.meta("fragments", [:]))
  }

  func spotDidReachEnd(_ completion: Completion) {
    let offset = spot(at: UI.playlists, Spotable.self)?.component.items.count ?? 0
    Malibu.networking("api").GET(PlaylistsRequest(offset: offset))
      .validate()
      .toJsonDictionary()
      .done { json in
        guard let items = json["items"] as? [[String : Any]] else { return }
        let viewModels = self.parse(items)

        self.append(viewModels, spotIndex: UI.playlists, withAnimation: .automatic)
        completion?()
    }
  }
}
