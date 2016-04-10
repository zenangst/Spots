import Spots
import Keychain
import Compass
import Brick

class FeaturedController: SpotsController {

  let accessToken = Keychain.password(forAccount: keychainAccount)

  convenience init(title: String) {
    let featuredPlaylists = GridSpot(component: Component(title: "Featured playlists", span: 3, items: [ViewModel(title: "Loading...")]))

    self.init(spot: featuredPlaylists)
    self.spotsDelegate = self
    self.spotsRefreshDelegate = self
    self.title = title
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    guard spot.items.count <= 1 else { return }

    loadData()
  }

  func loadData(completion: (() -> Void)? = nil) {
    SPTBrowse.requestFeaturedPlaylistsForCountry("NO", limit: 50, offset: 0, locale: nil, timestamp: nil, accessToken: accessToken) { (error, object) -> Void in
      guard let object = object as? SPTFeaturedPlaylistList else { return }

      self.update { $0.items = object.items.map { item in
        ViewModel(
          title: item.name,
          subtitle: "\(item.trackCount) songs",
          image: (item.largestImage as SPTImage).imageURL.absoluteString,
          kind: "featured",
          action: "playlist:" + (item.uri as NSURL).absoluteString.replace(":", with: "-"))
        }
        completion?()
      }
    }
  }
}

extension FeaturedController : SpotsDelegate {

  func spotDidSelectItem(spot: Spotable, item: ViewModel) {
    guard let urn = item.action else { return }
    Compass.navigate(urn)
  }
}

extension FeaturedController : SpotsRefreshDelegate {

  func spotsDidReload(refreshControl: UIRefreshControl, completion: (() -> Void)?) {
    loadData(completion)
  }
}
