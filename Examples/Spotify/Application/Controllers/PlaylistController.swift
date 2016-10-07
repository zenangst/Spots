import Spots
import Keychain
import Whisper
import Compass
import Sugar
import Hue
import Brick

class PlaylistController: Controller {

  let accessToken = Keychain.password(forAccount: keychainAccount)
  var playlistID: String?
  var offset = 0
  var playlistPage: SPTListPage?
  var currentURIs = [URL]()

  convenience init(playlistID: String?) {
    let featuredSpot = CarouselSpot(Component(span: 2), top: 5, left: 15, bottom: 5, right: 15, itemSpacing: 15)
    let gridSpot = GridSpot(component: Component(span: 1))
    let listSpot = ListSpot(title: "Playlists").then {
      $0.component.meta["headerHeight"] = 44
      $0.items = [Item(title: "Loading...", kind: "playlist", size: CGSize(width: 44, height: 44))]
    }

    self.init(spots: [gridSpot, featuredSpot, listSpot])
    self.playlistID = playlistID
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    delegate = self
    scrollView.backgroundColor = UIColor.black
    refreshDelegate = self
    scrollDelegate = self
    view.backgroundColor = UIColor.black

    if playlistID == nil {
      refreshData()
    }
  }

  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    super.scrollViewDidScroll(scrollView)

    guard let delegate = UIApplication.shared.delegate as? AppDelegate, !delegate.mainController.playerController.player.isPlaying else { return }

    delegate.mainController.playerController.hidePlayer()
  }

  func refreshData(_ closure: (() -> Void)? = nil) {
    currentURIs.removeAll()

    if let playlistID = playlistID {
      let uri = playlistID.replace("-", with: ":")

      self.title = "Loading..."

      SPTPlaylistSnapshot.playlist(withURI: URL(string:uri), accessToken: accessToken, callback: { (error, object) -> Void in
        guard let object = object as? SPTPlaylistSnapshot,
        let firstTrackPage = object.firstTrackPage
          else { return }

        self.title = object.name

        var viewModels = firstTrackPage.viewModels(playlistID)
        self.currentURIs.append(contentsOf: firstTrackPage.uris())

        if let first = viewModels.first,
          let imageString = first.meta["image"] as? String,
          let url = NSURL(string: imageString),
          let data = NSData(contentsOf: url as URL),
          let image = UIImage(data: data as Data) {
          let (background, primary, secondary, detail) = image.colors(CGSize(width: 128, height: 128))
          viewModels.enumerated().forEach {
            viewModels[$0.offset].meta["background"] = background
            viewModels[$0.offset].meta["primary"] = primary
            viewModels[$0.offset].meta["secondary"] = secondary
            viewModels[$0.offset].meta["detail"] = detail
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
      SPTPlaylistList.playlists(forUser: username, withAccessToken: accessToken) { (error, object) -> Void in
        guard let object = object as? SPTPlaylistList, object.items != nil
          else { return }

        var items = object.viewModels()

        var featured = items.filter {
          $0.title.lowercased().range(of: "top") != nil ||
          $0.title.lowercased().range(of: "starred")  != nil ||
          $0.title.lowercased().range(of: "discover") != nil
        }

        featured.enumerated().forEach { (index, item) in
          if let index = items.index(where: { $0 == item }) {
            items.remove(at: index)
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

extension PlaylistController: RefreshDelegate {

  func spotsDidReload(_ refreshControl: UIRefreshControl, completion: (() -> Void)?) {
    refreshData {
      refreshControl.endRefreshing()
      completion?()
    }
  }
}

extension PlaylistController: ScrollDelegate {

  func spotDidReachEnd(_ completion: (() -> Void)?) {
    guard let playlistPage = playlistPage else { return }

    playlistPage.requestNextPage(withAccessToken: accessToken, callback: { (error, object) -> Void in
      guard let object = object as? SPTListPage, object.items != nil
        else {
          completion?()
          return
      }

      var items = [Item]()

      if let playlistID = self.playlistID, let listSpot = self.spot(at: 2, Spotable.self) {
        items.append(contentsOf: object.viewModels(playlistID, offset: listSpot.items.count))
        self.currentURIs.append(contentsOf: object.uris())

        if let firstItem = listSpot.items.first {
          for (index, _) in items.enumerated() {
            items[index].meta["background"] = firstItem.meta["background"] ?? ""
            items[index].meta["primary"] = firstItem.meta["primary"] ?? ""
            items[index].meta["secondary"] = firstItem.meta["secondary"] ?? ""
            items[index].meta["detail"] = firstItem.meta["detail"] ?? ""
          }
        }
        self.append(items, spotIndex: 2)
      } else {
        items.append(contentsOf: object.viewModels())

        var featured = items.filter {
          $0.title.lowercased().range(of: "top")  != nil ||
            $0.title.lowercased().range(of: "starred") != nil ||
            $0.title.lowercased().range(of: "discover") != nil
        }

        featured.enumerated().forEach { (index, item) in
          if let index = items.index(where: { $0 == item }) {
            items.remove(at: index)
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

  func didSelect(item: Item, in spot: Spotable) {
    if let delegate = UIApplication.shared.delegate as? AppDelegate,
      let playlist = spot as? ListSpot {
        delegate.mainController.playerController.lastItem = item
        delegate.mainController.playerController.currentURIs = currentURIs
        if item.image.isPresent {
          delegate.mainController.playerController.currentAlbum.setImage(URL(string: item.image)!)
        }
        delegate.mainController.playerController.update(spotAtIndex: 1) {
          $0.items = playlist.items.map {
            Item(title: $0.title,
              subtitle: $0.subtitle,
              image: $0.meta("image", type: String.self) ?? $0.image,
              kind: "featured",
              action: $0.action,
              size: CGSize(
                width: UIScreen.main.bounds.width,
                height: UIScreen.main.bounds.width)
            )
          }

          ($0 as? CarouselSpot)?.scrollTo { item.action == $0.action }
        }
    }

    guard let urn = item.action else { return }

    if let carouselSpot = spot as? CarouselSpot,
      let cell = carouselSpot.collectionView.cellForItem(at: IndexPath(item: item.index, section: 0)) {
        UIView.animate(withDuration: 0.125, animations: { () -> Void in
          cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
          }) { _ in
            Compass.navigate(to: urn)
            UIView.animate(withDuration: 0.125) { cell.transform = CGAffineTransform.identity }
        }
    } else {
      Compass.navigate(to: urn)
    }

    if let notification = item.meta["notification"] as? String {
      let murmur = Murmur(title: notification,
        backgroundColor: UIColor(red:0.063, green:0.063, blue:0.063, alpha: 1),
        titleColor: UIColor.white)
      Whisper.show(whistle: murmur)
    }
  }
}
