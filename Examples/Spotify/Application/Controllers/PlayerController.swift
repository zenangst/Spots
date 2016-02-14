import Spots
import Compass
import Keychain
import Imaginary
import Sugar

class PlayerController: SpotsController {

  let screenBounds = UIScreen.mainScreen().bounds
  var initialOrigin: CGFloat = UIScreen.mainScreen().bounds.height - 108
  let offset: CGFloat = 108
  var lastItem: ViewModel?
  var currentURIs = [NSURL]()

  lazy var panRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
  lazy var tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTapGesture:")

  lazy var currentAlbum = UIImageView()

  lazy var player: SPTAudioStreamingController = {
    let player = SPTAudioStreamingController(clientId: SPTAuth.defaultInstance().clientID)
    player.playbackDelegate = self

    return player
  }()

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

    currentAlbum.addObserver(self, forKeyPath: "image", options: [.New, .Old], context: nil)
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if let imageView = object as? UIImageView,
      image = imageView.image
      where keyPath == "image" {
        dispatch(queue: .Interactive) {
          let (background, primary, secondary, detail) = image.colors(CGSize(width: 128, height: 128))
          dispatch { [weak self] in
            guard let background = background else { return }

            if let listSpot = self?.spot(0) as? ListSpot {
              var item = listSpot.items[0]

              item.meta["background"] = background
              item.meta["textColor"] = primary
              item.meta["secondary"] = secondary

              self?.update(item, index: 0, spotIndex: 0)
            }

            if let listSpot = self?.spot(2) as? ListSpot {
              var item = listSpot.items[0]

              item.meta["background"] = background
              item.meta["textColor"] = primary
              item.meta["secondary"] = secondary

              self?.update(item, index: 0, spotIndex: 2)
            }

            if let gridSpot = self?.spot(3) as? GridSpot {
              var items = gridSpot.items
              items.enumerate().forEach {
                items[$0.index].meta["textColor"] = secondary
                items[$0.index].meta["tintColor"] = detail
              }

              self?.update(spotAtIndex: 3, {
                $0.items = items
              })
            }

            UIView.animateWithDuration(0.3) {
              self?.spotsScrollView.backgroundColor = background
              self?.view.backgroundColor = background
            }
          }
        }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    spotsDelegate = self
  }

  func updatePlayer(userInfo: [String : String]) {
    if let track = userInfo["track"],
      artist = userInfo["artist"] {

        var newViewModel: ViewModel
        if let spot = spot(0), item = spot.items.first {
          newViewModel = item
          newViewModel.title = track
          newViewModel.subtitle = artist
          update(newViewModel, index: 0, spotIndex: 0)
          newViewModel.action = nil
          update(newViewModel, index: 0, spotIndex: 2)
        } else {
          newViewModel = ViewModel(title: track, subtitle: artist, action: "openPlayer")

          insert(newViewModel, index: 0, spotIndex: 0)
          newViewModel.action = nil
          insert(newViewModel, index: 0, spotIndex: 2)
        }

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
        }, completion: { _ in })

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

      if let lastItem = lastItem where !lastItem.image.isEmpty {
        currentAlbum.setImage(NSURL(string: lastItem.image)!)
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

  func spotDidSelectItem(spot: Spotable, item: ViewModel) {
    guard let urn = item.action else { return }

    if !["next", "previous"].contains(urn) {
      Compass.navigate(urn)
      return
    }

    if let carouselSpot = self.spot(1) as? CarouselSpot,
      lastItem = lastItem {
        guard let currentIndex = carouselSpot.items.indexOf({ $0.action == lastItem.action }) else { return }
        var newIndex = currentIndex

        switch urn {
        case "next":     newIndex = newIndex + 1
        case "previous": newIndex = newIndex - 1
        default: break
        }

        guard newIndex >= 0 && newIndex < carouselSpot.items.count  else { return }
        let item = carouselSpot.items[newIndex]
        carouselSpot.scrollTo({ item.action == $0.action })
        self.lastItem = item
        guard let urn = item.action else { return }
        Compass.navigate(urn)

        if !item.image.isEmpty {
          currentAlbum.setImage(NSURL(string: item.image)!)
        }
    }
  }
}

extension PlayerController: SpotsCarouselScrollDelegate {

  func spotDidEndScrolling(spot: Spotable, item: ViewModel) {
    guard let urn = item.action, lastItem = lastItem
      where item.action != lastItem.action
      else { return }

    Compass.navigate(urn)
    self.lastItem = item

    if !item.image.isEmpty {
      currentAlbum.setImage(NSURL(string: item.image)!)
    }
  }
}

extension PlayerController: SPTAudioStreamingPlaybackDelegate {

  func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangeToTrack trackMetadata: [NSObject : AnyObject]!) {

    guard let name = trackMetadata["SPTAudioStreamingMetadataArtistName"] as? String,
      artist = trackMetadata["SPTAudioStreamingMetadataArtistName"] as? String,
      track = trackMetadata["SPTAudioStreamingMetadataTrackName"] as? String
      else { return }

    updatePlayer([
      "title" : name,
      "artist" :artist,
      "track" : track
      ])
  }
}
