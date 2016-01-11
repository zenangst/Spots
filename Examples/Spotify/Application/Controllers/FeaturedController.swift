import Spots
import Keychain
import Compass

class FeaturedController: SpotsController, SpotsDelegate {

  let accessToken = Keychain.password(forAccount: keychainAccount)

  convenience init(title: String) {
    let featuredPlaylists = GridSpot(component: Component(title: "Featured playlists", span: 3, items: [ListItem(title: "Loading...")]))

    self.init(spot: featuredPlaylists)
    self.spotsDelegate = self
    self.title = title

    SPTBrowse.requestFeaturedPlaylistsForCountry("NO", limit: 50, offset: 0, locale: nil, timestamp: nil, accessToken: accessToken) { (error, object) -> Void in
      guard let object = object as? SPTFeaturedPlaylistList else { return }

      self.update { $0.items = object.items.map { item in
        ListItem(
          title: item.name,
          subtitle: "\(item.trackCount) songs",
          image: (item.largestImage as SPTImage).imageURL.absoluteString,
          kind: "featured",
          action: "playlist:" + (item.uri as NSURL).absoluteString.replace(":", with: "-"))
        }
      }
    }
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    spotsScrollView.contentInset.bottom = 120
  }

  func spotDidSelectItem(spot: Spotable, item: ListItem) {
    guard let urn = item.action else { return }

    if let gridSpot = spot as? GridSpot,
    cell = gridSpot.collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: item.index, inSection: 0)) {
      UIView.animateWithDuration(0.125, animations: { () -> Void in
        cell.transform = CGAffineTransformMakeScale(0.8, 0.8)
        }) { _ in
          Compass.navigate(urn)
          UIView.animateWithDuration(0.125) { cell.transform = CGAffineTransformIdentity }
      }
    } else {
      Compass.navigate(urn)
    }
  }
}
