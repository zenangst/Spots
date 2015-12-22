import Spots
import Keychain
import Compass

class FeaturedController: SpotsController, SpotsDelegate {

  let accessToken = Keychain.password(forAccount: keychainAccount)

  convenience init(title: String) {
    let navigation = ListSpot(component: Component(items:[
      ListItem(title: "Playlists", image: "playlist", action: "playlists")
      ]))
    let recentlyPlayed = ListSpot(component: Component(title: "Featured playlists", items: [
      ListItem(title: "Loading...")
      ]))

    self.init(spots: [navigation, recentlyPlayed])
    self.spotsDelegate = self
    self.title = title

    SPTBrowse.requestFeaturedPlaylistsForCountry("NO", limit: 50, offset: 0, locale: nil, timestamp: nil, accessToken: accessToken) { (error, object) -> Void in

      if let error = error {
        print(error)
      }
      if let object = object as? SPTFeaturedPlaylistList {
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

        self.update(spotAtIndex: 1) { $0.items = listItems }
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.blackColor()
    spotsScrollView.backgroundColor = UIColor.blackColor()
  }

  func spotDidSelectItem(spot: Spotable, item: ListItem) {
    guard let urn = item.action else { return }
    Compass.navigate(urn)
  }
}
