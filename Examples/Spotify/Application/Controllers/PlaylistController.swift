import Spots
import Keychain

class PlaylistController: SpotsController {

  let accessToken = Keychain.password(forAccount: keychainAccount)
  var playlistID: String?

  convenience init(playlistID: String?) {
    let listSpot = ListSpot(component: Component())

    self.init(spots: [listSpot])
    self.view.backgroundColor = UIColor.blackColor()
    self.container.backgroundColor = UIColor.blackColor()

    if let playlistID = playlistID {
      let uri = playlistID.stringByReplacingOccurrencesOfString("-", withString: ":")
      let url = NSURL(string:uri)

      self.title = "Loading..."
      SPTPlaylistSnapshot.playlistWithURI(url, accessToken: accessToken, callback: { (error, object) -> Void in
        if let object = object as? SPTPlaylistSnapshot {
          self.title = object.name

          var listItems = [ListItem]()

          listItems.append(ListItem(
            title: "Stop",
            kind: "playlist",
            action: "stop"
            ))

          for item in object.firstTrackPage.items {
            let uri = (item.uri as NSURL).absoluteString
              .stringByReplacingOccurrencesOfString(":", withString: "-")

            listItems.append(ListItem(
              title: item.name,
              subtitle:  "\(((item.artists as! [SPTPartialArtist]).first)!.name) - \((item.album as SPTPartialAlbum).name)",
              kind: "playlist",
              action: "play:\(uri)"
              ))
          }

          self.updateSpotAtIndex(0, closure: { spot -> Spotable in
            spot.items = listItems
            return spot
          })
        }
      })
    } else {
      SPTPlaylistList.playlistsForUser(NSProcessInfo.processInfo().environment["spotifyUsername"], withAccessToken: accessToken) { (error, object) -> Void in
        if let object = object as? SPTPlaylistList {
          var listItems = [ListItem]()
          for item in object.items {
            let uri = (item.uri as NSURL).absoluteString
              .stringByReplacingOccurrencesOfString(":", withString: "-")

            let image: String = (item.largestImage as SPTImage).imageURL.absoluteString

            listItems.append(ListItem(
              title: item.name,
              subtitle: "\(item.trackCount) songs",
              image: image,
              kind: "playlist",
              action: "playlist:" + uri
              ))
          }

          self.updateSpotAtIndex(0, closure: { spot -> Spotable in
            spot.items = listItems
            return spot
          })
        }
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    spotsDelegate = self

    updateSpotAtIndex(0, closure: { spot -> Spotable in
      spot.items = [ListItem(title: "Loading...", kind: "playlist", size: CGSize(width: 44, height: 44))]
      return spot
    })
  }
}
