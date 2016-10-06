import Spots
import Compass
import Keychain
import Imaginary
import Sugar
import Brick

class PlayerController: Controller {

  let screenBounds = UIScreen.main.bounds
  var initialOrigin: CGFloat = UIScreen.main.bounds.height - 108
  let offset: CGFloat = 108
  var lastItem: Item?
  var currentURIs = [URL]()

  lazy var panRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(PlayerController.handlePanGesture(_:)))
  lazy var tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PlayerController.handleTapGesture(_:)))

  lazy var currentAlbum = UIImageView()

  lazy var player: SPTAudioStreamingController = {
    let player = SPTAudioStreamingController(clientId: SPTAuth.defaultInstance().clientID)
    player?.playbackDelegate = self

    return player!
  }()

  required init(spots: [Spotable]) {
    super.init(spots: spots)

    view.backgroundColor = UIColor.black.withAlphaComponent(0.9)
    spotsScrollView.isScrollEnabled = false
    spotsScrollView.backgroundColor = UIColor.clear

    if let listSpot = spot(at: 0, ListSpot.self) {
      listSpot.tableView.separatorStyle = .none
    }

    if let carouselSpot = spot(at: 1, CarouselSpot.self) {
      carouselSpot.paginate = true
      carouselSpot.carouselScrollDelegate = self
    }

    view.addGestureRecognizer(panRecognizer)

    NotificationCenter.default.addObserver(self, selector: #selector(PlayerController.updatePlayer(_:)), name: NSNotification.Name(rawValue: "updatePlayer"), object: nil)

    currentAlbum.addObserver(self, forKeyPath: "image", options: [.new, .old], context: nil)
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if let imageView = object as? UIImageView,
      let image = imageView.image, keyPath == "image" {
        dispatch(queue: .interactive) {
          let (background, primary, secondary, detail) = image.colors(CGSize(width: 128, height: 128))
          dispatch { [weak self] in
            if let listSpot = self?.spot(at: 0, ListSpot.self) {
              var item = listSpot.items[0]

              item.meta["background"] = background
              item.meta["textColor"] = primary
              item.meta["secondary"] = secondary

              self?.update(item, index: 0, spotIndex: 0)
            }

            if let listSpot = self?.spot(at: 2, ListSpot.self) {
              var item = listSpot.items[0]

              item.meta["background"] = background
              item.meta["textColor"] = primary
              item.meta["secondary"] = secondary

              self?.update(item, index: 0, spotIndex: 2)
            }

            if let gridSpot = self?.spot(at: 3, GridSpot.self) {
              var items = gridSpot.items
              items.enumerated().forEach {
                items[$0.offset].meta["textColor"] = secondary
                items[$0.offset].meta["tintColor"] = detail
              }

              self?.update(spotAtIndex: 3, withAnimation: .automatic) {
                $0.items = items
              }
            }

            UIView.animate(withDuration: 0.3) {
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

  func updatePlayer(_ userInfo: [String : String]) {
    if let track = userInfo["track"],
      let artist = userInfo["artist"] {

        var newItem: Item
        if let spot = spot(at: 0, Spotable.self), let item = spot.items.first {
          newItem = item
          newItem.title = track
          newItem.subtitle = artist
          update(newItem, index: 0, spotIndex: 0)
          newItem.action = nil
          update(newItem, index: 0, spotIndex: 2)
        } else {
          newItem = Item(title: track, subtitle: artist, action: "openPlayer")

          insert(newItem, index: 0, spotIndex: 0)
          newItem.action = nil
          insert(newItem, index: 0, spotIndex: 2)
        }

        showPlayer()
    }
  }

  func handleTapGesture(_ gesture: UITapGestureRecognizer) {
    let minimumY: CGFloat = -60
    let maximumY: CGFloat = UIScreen.main.bounds.height - offset

    if view.y == maximumY {
      UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction], animations: {
        self.view.y = minimumY
        UIApplication.shared.isStatusBarHidden = true
        }, completion: nil)
    }
  }

  func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
    let minimumY: CGFloat = -60
    let maximumY: CGFloat = UIScreen.main.bounds.height - offset
    let translation = gesture.translation(in: self.view)
    let velocity = gesture.velocity(in: self.view)

    switch gesture.state {
    case .began:
      initialOrigin = view.y
    case .changed:
      if initialOrigin + translation.y < minimumY {
        view.y = minimumY
      } else if view.y > maximumY {
        view.y = maximumY
      } else if view.y <= maximumY {
        view.y = initialOrigin + translation.y
      }
    case .ended, .cancelled:
      let endY = velocity.y <= 0 ? minimumY : maximumY
      var time = maximumY / abs(velocity.y)
      if time > 1 {
        time = 0.7
      }

      UIView.animate(withDuration: TimeInterval(time), delay: 0, options: [.allowUserInteraction], animations: {
        self.view.y = endY
//        UIApplication.sharedApplication.statusBarHidden = endY == minimumY
        }, completion: { _ in })

    default: break
    }
  }

  func openPlayer() {
    UIView.animate(withDuration: 0.3) {
      self.view.y = -60
    }
  }

  func showPlayer() {
    if view.y == UIScreen.main.bounds.height {
      UIView.animate(withDuration: 0.3) {
        self.view.y -= self.offset
      }

      if let lastItem = lastItem, lastItem.image.isPresent {
        currentAlbum.setImage(URL(string: lastItem.image)!)
      }
    }
  }

  func hidePlayer() {
    UIView.animate(withDuration: 0.3) {
      self.view.y = UIScreen.main.bounds.height
    }
  }
}

extension PlayerController: SpotsDelegate {

  func spotDidSelectItem(_ spot: Spotable, item: Item) {
    guard let urn = item.action else { return }

    if !["next", "previous"].contains(urn) {
      Compass.navigate(to: urn)
      return
    }

    if let carouselSpot = self.spot(at: 1, CarouselSpot.self),
      let lastItem = lastItem {
        guard let currentIndex = carouselSpot.items.index(where: { $0.action == lastItem.action }) else { return }
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
        Compass.navigate(to: urn)

        if item.image.isPresent {
          currentAlbum.setImage(URL(string: item.image)!)
        }
    }
  }
}

extension PlayerController: SpotsCarouselScrollDelegate {

  func spotDidScroll(_ spot: Spotable) { }

  func spotDidEndScrolling(_ spot: Spotable, item: Item) {
    guard let urn = item.action, let lastItem = lastItem, item.action != lastItem.action
      else { return }

    Compass.navigate(to: urn)
    self.lastItem = item

    if item.image.isPresent {
      currentAlbum.setImage(URL(string: item.image)!)
    }
  }
}

extension PlayerController: SPTAudioStreamingPlaybackDelegate {

  func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangeToTrack trackMetadata: [AnyHashable: Any]!) {

    guard let name = trackMetadata["SPTAudioStreamingMetadataArtistName"] as? String,
      let artist = trackMetadata["SPTAudioStreamingMetadataArtistName"] as? String,
      let track = trackMetadata["SPTAudioStreamingMetadataTrackName"] as? String
      else { return }

    updatePlayer([
      "title" : name,
      "artist" :artist,
      "track" : track
      ])
  }
}
