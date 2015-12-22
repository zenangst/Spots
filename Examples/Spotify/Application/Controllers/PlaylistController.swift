import Spots
import Keychain
import Whisper
import Compass
import Sugar

class PlaylistController: SpotsController {

  let accessToken = Keychain.password(forAccount: keychainAccount)
  var playlistID: String?
  var offset = 0

  convenience init(playlistID: String?) {
    let listSpot = ListSpot(component: Component())

    self.init(spots: [listSpot])
    self.view.backgroundColor = UIColor.blackColor()
    self.spotsScrollView.backgroundColor = UIColor.blackColor()

    if let playlistID = playlistID {
      let uri = playlistID.replace("-", with: ":")

      self.title = "Loading..."
      SPTPlaylistSnapshot.playlistWithURI(NSURL(string:uri), accessToken: accessToken, callback: { (error, object) -> Void in
        guard let object = object as? SPTPlaylistSnapshot else { return }

        self.title = object.name

        var listItems = [ListItem]()

        object.firstTrackPage.items.enumerate().forEach { index, item in
          let image: String = (item.album as SPTPartialAlbum).largestCover.imageURL.absoluteString

          listItems.append(ListItem(
            title: item.name,
            subtitle:  "\(((item.artists as! [SPTPartialArtist]).first)!.name) - \((item.album as SPTPartialAlbum).name)",
            kind: "playlist",
            action: "play:\(playlistID):\(index)",
            meta: [
              "notification" : "\(item.name) by \(((item.artists as! [SPTPartialArtist]).first)!.name)",
              "track" : item.name,
              "artist" : ((item.artists as! [SPTPartialArtist]).first)!.name,
              "image" : image
            ]
            ))
        }

        self.update { $0.items = listItems }
      })
    } else {
      SPTPlaylistList.playlistsForUser(username, withAccessToken: accessToken) { (error, object) -> Void in
        guard let object = object as? SPTPlaylistList else { return }
        
        var listItems = [ListItem]()

        object.items.forEach { item in
          let uri = (item.uri as NSURL).absoluteString.replace(":", with: "-")
          let image: String = (item.largestImage as SPTImage).imageURL.absoluteString

          listItems.append(ListItem(
            title: item.name,
            subtitle: "\(item.trackCount) songs",
            image: image,
            kind: "playlist",
            action: "playlist:" + uri
            ))
        }

        self.update { $0.items = listItems }
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    spotsDelegate = self

    update {
      $0.items = [ListItem(title: "Loading...", kind: "playlist", size: CGSize(width: 44, height: 44))]
    }
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    spotsScrollView.contentInset.bottom = 120
  }
}

extension PlaylistController: SpotsDelegate {

  func spotDidSelectItem(spot: Spotable, item: ListItem) {
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
