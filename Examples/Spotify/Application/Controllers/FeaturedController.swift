import Spots
import Keychain
import Compass
import Brick

class FeaturedController: Controller {

  let accessToken = Keychain.password(forAccount: keychainAccount)

  convenience init(title: String) {
    let featuredPlaylists = GridSpot(component: Component(title: "Featured playlists", span: 3, items: [Item(title: "Loading...")]))

    self.init(spot: featuredPlaylists)
    self.delegate = self
    self.refreshDelegate = self
    self.title = title
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    guard (spot?.items.count)! <= 1 else { return }

    loadData()
  }

  func loadData(_ completion: (() -> Void)? = nil) {
    SPTBrowse.requestFeaturedPlaylists(forCountry: "NO", limit: 50, offset: 0, locale: nil, timestamp: nil, accessToken: accessToken) { (error, object) -> Void in
      guard let object = object as? SPTFeaturedPlaylistList else { return }

      self.update { $0.items = object.items.map { item in
        Item(
          title: (item as AnyObject).name,
          subtitle: "\((item as AnyObject).trackCount) songs",
          image: ((item as AnyObject).largestImage as SPTImage).imageURL.absoluteString,
          kind: "featured",
          action: "playlist:" + (((item as AnyObject).uri as NSURL).absoluteString?.replace(":", with: "-"))!)
        }
        completion?()
      }
    }
  }
}

extension FeaturedController : SpotsDelegate {

  func spotDidSelectItem(_ spot: Spotable, item: Item) {
    guard let urn = item.action else { return }
    Compass.navigate(to: urn)
  }
}

extension FeaturedController : SpotsRefreshDelegate {

  func spotsDidReload(_ refreshControl: UIRefreshControl, completion: (() -> Void)?) {
    loadData(completion)
  }
}
