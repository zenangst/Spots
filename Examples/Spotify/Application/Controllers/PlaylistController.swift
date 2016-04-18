import Spots
import Keychain
import Whisper
import Compass
import Sugar
import Hue
import Brick

class PlaylistController: SpotsController {

  let accessToken = Keychain.password(forAccount: keychainAccount)
  var playlistID: String?
  var offset = 0
  var playlistPage: SPTListPage?
  var currentURIs = [NSURL]()

  convenience init(playlistID: String?) {
    let featuredSpot = CarouselSpot(Component(span: 2), top: 5, left: 15, bottom: 5, right: 15, itemSpacing: 15)
    let gridSpot = GridSpot(component: Component(span: 1))
    let listSpot = ListSpot(title: "Playlists").then {
      $0.component.meta["headerHeight"] = 44
      $0.items = [ViewModel(title: "Loading...", kind: "playlist", size: CGSize(width: 44, height: 44))]
    }

    self.init(spots: [gridSpot, featuredSpot, listSpot])
    self.playlistID = playlistID
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    spotsDelegate = self
    spotsScrollView.backgroundColor = UIColor.blackColor()
    spotsRefreshDelegate = self
    spotsScrollDelegate = self
    view.backgroundColor = UIColor.blackColor()

    if playlistID == nil {
      refreshData()
    }
  }

  override func scrollViewDidScroll(scrollView: UIScrollView) {
    super.scrollViewDidScroll(scrollView)

    guard let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
      where !delegate.mainController.playerController.player.isPlaying else { return }

    delegate.mainController.playerController.hidePlayer()
  }

  func refreshData(closure: (() -> Void)? = nil) {
    currentURIs.removeAll()

    if let playlistID = playlistID {
      let uri = playlistID.replace("-", with: ":")

      self.title = "Loading..."

      SPTPlaylistSnapshot.playlistWithURI(NSURL(string:uri), accessToken: accessToken, callback: { (error, object) -> Void in
        guard let object = object as? SPTPlaylistSnapshot,
        firstTrackPage = object.firstTrackPage
          else { return }

        self.title = object.name

        var viewModels = firstTrackPage.viewModels(playlistID)
        self.currentURIs.appendContentsOf(firstTrackPage.uris())

        if let first = viewModels.first,
          imageString = first.meta["image"] as? String,
          url = NSURL(string: imageString),
          data = NSData(contentsOfURL: url),
          image = UIImage(data: data)
        {
          let (background, primary, secondary, detail) = image.colors(CGSize(width: 128, height: 128))
          viewModels.enumerate().forEach {
            viewModels[$0.index].meta["background"] = background
            viewModels[$0.index].meta["primary"] = primary
            viewModels[$0.index].meta["secondary"] = secondary
            viewModels[$0.index].meta["detail"] = detail
          }

          self.update(spotAtIndex: 2) { $0.items = viewModels }

          var top = first
          top.image = object.largestImage.imageURL.absoluteString
          top.action = ""

          self.update(spotAtIndex: 0) { $0.items = [top] }

          self.playlistPage = object.firstTrackPage.hasNextPage ? object.firstTrackPage : nil

          closure?()
        }
      })
    } else {
      SPTPlaylistList.playlistsForUser(username, withAccessToken: accessToken) { (error, object) -> Void in
        guard let object = object as? SPTPlaylistList
          where object.items != nil
          else { return }

        var items = object.viewModels()

        var featured = items.filter {
          $0.title.lowercaseString.containsString("top") ||
          $0.title.lowercaseString.containsString("starred") ||
          $0.title.lowercaseString.containsString("discover")
        }

        featured.enumerate().forEach { (index, item) in
          if let index = items.indexOf({ $0 == item }) {
            items.removeAtIndex(index)
          }

          featured[index].size = CGSize(width: 120, height: 140)
        }

        self.update(spotAtIndex: 2) { $0.items = items }
        self.update(spotAtIndex: 1) { $0.items = featured }
        closure?()

        self.playlistPage = object.hasNextPage ? object : nil
      }
    }
  }
}

extension PlaylistController: SpotsRefreshDelegate {

  func spotsDidReload(refreshControl: UIRefreshControl, completion: (() -> Void)?) {
    refreshData {
      refreshControl.endRefreshing()
      completion?()
    }
  }
}

extension PlaylistController: SpotsScrollDelegate {

  func spotDidReachEnd(completion: (() -> Void)?) {
    guard let playlistPage = playlistPage else { return }

    playlistPage.requestNextPageWithAccessToken(accessToken, callback: { (error, object) -> Void in
      guard let object = object as? SPTListPage
        where object.items != nil
        else {
          completion?()
          return
      }

      var items = [ViewModel]()

      if let playlistID = self.playlistID, listSpot = self.spot(2, Spotable.self) {
        items.appendContentsOf(object.viewModels(playlistID, offset: listSpot.items.count))
        self.currentURIs.appendContentsOf(object.uris())

        if let firstItem = listSpot.items.first {
          for (index, _) in items.enumerate() {
            items[index].meta["background"] = firstItem.meta["background"] ?? ""
            items[index].meta["primary"] = firstItem.meta["primary"] ?? ""
            items[index].meta["secondary"] = firstItem.meta["secondary"] ?? ""
            items[index].meta["detail"] = firstItem.meta["detail"] ?? ""
          }
        }
        self.append(items, spotIndex: 2)
      } else {
        items.appendContentsOf(object.viewModels())

        var featured = items.filter {
          $0.title.lowercaseString.containsString("top") ||
          $0.title.lowercaseString.containsString("starred") ||
          $0.title.lowercaseString.containsString("discover")
        }

        featured.enumerate().forEach { (index, item) in
          if let index = items.indexOf({ $0 == item }) {
            items.removeAtIndex(index)
          }

          featured[index].size = CGSize(width: 120, height: 140)
        }

        self.append(items, spotIndex: 2)
        self.append(featured, spotIndex: 1)
      }

      self.playlistPage = object.hasNextPage ? object : nil

      completion?()
    })
  }
}

extension PlaylistController: SpotsDelegate {

  func spotDidSelectItem(spot: Spotable, item: ViewModel) {
    if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate,
      playlist = spot as? ListSpot {
        delegate.mainController.playerController.lastItem = item
        delegate.mainController.playerController.currentURIs = currentURIs
        if item.image.isPresent {
          delegate.mainController.playerController.currentAlbum.setImage(NSURL(string: item.image)!)
        }
        delegate.mainController.playerController.update(spotAtIndex: 1) {
          $0.items = playlist.items.map {
            ViewModel(title: $0.title,
              subtitle: $0.subtitle,
              image: $0.meta("image", type: String.self) ?? $0.image,
              kind: "featured",
              action: $0.action,
              size: CGSize(
                width: UIScreen.mainScreen().bounds.width,
                height: UIScreen.mainScreen().bounds.width)
            )
          }

          ($0 as? CarouselSpot)?.scrollTo { item.action == $0.action }
        }
    }

    guard let urn = item.action else { return }

    if let carouselSpot = spot as? CarouselSpot,
      cell = carouselSpot.collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: item.index, inSection: 0)) {
        UIView.animateWithDuration(0.125, animations: { () -> Void in
          cell.transform = CGAffineTransformMakeScale(0.8, 0.8)
          }) { _ in
            Compass.navigate(urn)
            UIView.animateWithDuration(0.125) { cell.transform = CGAffineTransformIdentity }
        }
    } else {
      Compass.navigate(urn)
    }

    if let notification = item.meta["notification"] as? String {
      let murmur = Murmur(title: notification,
        backgroundColor: UIColor(red:0.063, green:0.063, blue:0.063, alpha: 1),
        titleColor: UIColor.whiteColor())
      Whistle(murmur)
    }
  }
}
