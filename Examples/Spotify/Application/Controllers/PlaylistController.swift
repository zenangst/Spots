import Spots
import Keychain
import Whisper
import Compass
import Sugar
import Hue

class PlaylistController: SpotsController {

  let accessToken = Keychain.password(forAccount: keychainAccount)
  var playlistID: String?
  var offset = 0
  var playlistPage: SPTListPage?
  var currentURIs = [NSURL]()

  convenience init(playlistID: String?) {
    let listSpot = ListSpot().then {
      $0.items = [ListItem(title: "Loading...", kind: "playlist", size: CGSize(width: 44, height: 44))]
    }
    let featuredSpot = CarouselSpot(Component(span: 2), top: 5, left: 15, bottom: 5, right: 15, itemSpacing: 15)
    let gridSpot = GridSpot(component: Component(span: 1))

    self.init(spots: [gridSpot, featuredSpot, listSpot])
    self.view.backgroundColor = UIColor.blackColor()
    self.spotsScrollView.backgroundColor = UIColor.blackColor()
    self.spotsRefreshDelegate = self
    self.spotsScrollDelegate = self
    self.playlistID = playlistID

    refreshData()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    spotsDelegate = self
  }

  override func scrollViewDidScroll(scrollView: UIScrollView) {
    super.scrollViewDidScroll(scrollView)

    if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
      where !delegate.mainController.playerController.player.isPlaying {
        delegate.mainController.playerController.hidePlayer()
    }
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

        var listItems = firstTrackPage.listItems(playlistID)
        self.currentURIs.appendContentsOf(firstTrackPage.uris())

        if let first = listItems.first,
          imageString = first.meta["image"] as? String,
          url = NSURL(string: imageString),
          data = NSData(contentsOfURL: url),
          image = UIImage(data: data)
        {
          let (background, primary, secondary, detail) = image.colors(CGSize(width: 128, height: 128))
          if let background = background, primary = primary, secondary = secondary, detail = detail {
            listItems.enumerate().forEach {
              listItems[$0.index].meta["background"] = background
              listItems[$0.index].meta["primary"] = primary
              listItems[$0.index].meta["secondary"] = secondary
              listItems[$0.index].meta["detail"] = detail
            }
          }

          self.update(spotAtIndex: 2) { $0.items = listItems }

          var top = first
          top.image = object.largestImage.imageURL.absoluteString

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

        var items = object.listItems()

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

      var items = [ListItem]()

      if let playlistID = self.playlistID, listSpot = self.spot(2) {
        items.appendContentsOf(object.listItems(playlistID, offset: listSpot.items.count))
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
        items.appendContentsOf(object.listItems())

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

  func spotDidSelectItem(spot: Spotable, item: ListItem) {
    if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate,
      playList = spot as? ListSpot {
        delegate.mainController.playerController.currentURIs = currentURIs
        delegate.mainController.playerController.update(spotAtIndex: 1) {
          $0.items = playList.items.map {
            ListItem(title: $0.title,
              subtitle: $0.subtitle,
              image: $0.image,
              kind: "featured",
              action: $0.action,
              size: CGSize(
                width: UIScreen.mainScreen().bounds.width,
                height: UIScreen.mainScreen().bounds.width)
            )
          }
        }

        if let carouselSpot = delegate.mainController.playerController.spot(1) as? CarouselSpot {
          delegate.mainController.playerController.lastItem = item
          carouselSpot.scrollTo { item.action == $0.action }
        }
    }

    guard let urn = item.action else { return }
    Compass.navigate(urn)

    if let notification = item.meta["notification"] as? String {
      let murmur = Murmur(title: notification,
        backgroundColor: UIColor(red:0.063, green:0.063, blue:0.063, alpha: 1),
        titleColor: UIColor.whiteColor())
      Whistle(murmur)
    }
  }
}
