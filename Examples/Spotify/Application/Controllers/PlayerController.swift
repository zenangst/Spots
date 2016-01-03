import Spots
import Compass

class PlayerController: SpotsController {

  let screenBounds = UIScreen.mainScreen().bounds
  var initialOrigin: CGFloat = UIScreen.mainScreen().bounds.height - 108
  let offset: CGFloat = 108
  var lastItem: ListItem?

  lazy var panRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
  lazy var tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTapGesture:")

  required init(spots: [Spotable]) {
    super.init(spots: spots)

    view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.9)
    spotsScrollView.scrollEnabled = false
    spotsScrollView.backgroundColor = UIColor.clearColor()

    if let listSpot = spot(0) as? ListSpot {
      listSpot.tableView.separatorStyle = .None
    }

    if let carouselSpot = spot(1) as? CarouselSpot {
      carouselSpot.paginate = true
      carouselSpot.carouselScrollDelegate = self
    }

    view.addGestureRecognizer(panRecognizer)

    NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatePlayer:", name: "updatePlayer", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "hidePlayer", name: "hidePlayer", object: nil)
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    spotsDelegate = self
  }

  func updatePlayer(notification: NSNotification) {
    if let userInfo = notification.userInfo,
      track = userInfo["track"] as? String,
      artist = userInfo["artist"] as? String,
      image = userInfo["image"] as? String {
//        smallAlbumTrack.text = track
//        smallAlbumArtist.text = artist
//        albumCover.setImage(NSURL(string: image))
//        albumTrack.text = track
//        albumArtist.text = artist

        self.update {
          $0.items = [ListItem(title: track, subtitle: artist, action: "openPlayer")]
        }

        self.update(ListItem(title: track, subtitle: artist), index: 0, spotIndex: 2)

        showPlayer()
    }
  }

  func handleTapGesture(gesture: UITapGestureRecognizer) {
    let minimumY: CGFloat = -60
    let maximumY: CGFloat = UIScreen.mainScreen().bounds.height - offset

    if view.frame.origin.y == maximumY {
      UIView.animateWithDuration(0.2, delay: 0, options: [.AllowUserInteraction], animations: {
        self.view.frame.origin.y = minimumY
        UIApplication.sharedApplication().statusBarHidden = true
        }, completion: nil)
    }
  }

  func handlePanGesture(gesture: UIPanGestureRecognizer) {
    let minimumY: CGFloat = -60
    let maximumY: CGFloat = UIScreen.mainScreen().bounds.height - offset
    let translation = gesture.translationInView(self.view)
    let velocity = gesture.velocityInView(self.view)

    switch gesture.state {
    case .Began:
      initialOrigin = view.frame.origin.y
    case .Changed:
      if initialOrigin + translation.y < minimumY {
        view.frame.origin.y = minimumY
      } else if view.frame.origin.y > maximumY {
        view.frame.origin.y = maximumY
      } else if view.frame.origin.y <= maximumY {
        view.frame.origin.y = initialOrigin + translation.y
      }
    case .Ended, .Cancelled:
      let endY = velocity.y <= 0 ? minimumY : maximumY
      var time = maximumY / abs(velocity.y)
      if time > 1 {
        time = 0.7
      }

      UIView.animateWithDuration(NSTimeInterval(time), delay: 0, options: [.AllowUserInteraction], animations: {
        self.view.frame.origin.y = endY
        UIApplication.sharedApplication().statusBarHidden = endY == minimumY
        }, completion: { _ in
      })

    default: break
    }
  }

  func openPlayer() {
    UIView.animateWithDuration(0.3) {
      self.view.frame.origin.y = -60
    }
  }

  func showPlayer() {
    if view.frame.origin.y == UIScreen.mainScreen().bounds.height {
      UIView.animateWithDuration(0.3) {
        self.view.frame.origin.y -= self.offset
      }
    }
  }

  func hidePlayer() {
    UIView.animateWithDuration(0.3) {
      self.view.frame.origin.y = UIScreen.mainScreen().bounds.height
    }
  }
}

extension PlayerController: SpotsDelegate {

  func spotDidSelectItem(spot: Spotable, item: ListItem) {
    guard let urn = item.action else { return }
    Compass.navigate(urn)

    if let carouselSpot = self.spot(1) as? CarouselSpot,
      lastItem = lastItem {
        guard let currentIndex = carouselSpot.items.indexOf({ $0.action == lastItem.action }) else { return }
        var newIndex = currentIndex

        switch urn {
        case "next":
          newIndex = newIndex + 1
        case "previous":
          newIndex = newIndex - 1
        default: break
        }

        if newIndex >= 0 && newIndex <= carouselSpot.items.count {
          let item = carouselSpot.items[newIndex]
          carouselSpot.scrollTo({ item.action == $0.action })
          self.lastItem = item
        }
    }
  }
}

extension PlayerController: SpotsCarouselScrollDelegate {

  func spotDidEndScrolling(spot: Spotable, item: ListItem) {
    guard let urn = item.action else { return }
    if let lastItem = lastItem where item.action == lastItem.action { return }
    Compass.navigate(urn)
    lastItem = item
  }
}
