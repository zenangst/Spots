import Spots
import Compass
import Keychain
import Brick

class ProfileController: Controller {

  let accessToken = Keychain.password(forAccount: keychainAccount)

  convenience init(title: String) {
    let gridSpot = GridSpot().then {
      $0.component.span = 1
    }

    let listSpot = ListSpot().then {
      $0.component.meta["headerHeight"] = 44
      $0.component.title = "User information"
      $0.items = [Item(title: "Logout", action: "logout")]
    }

    self.init(spots: [gridSpot, listSpot])
    self.title = title
    self.delegate = self

    refreshData()
  }

  func refreshData() {
    SPTUser.request(username, withAccessToken: accessToken) { (error, object) -> Void in
      guard let user = object as? SPTUser, user.largestImage != nil else { return }
      let image = user.largestImage.imageURL.absoluteString

      self.update { $0.items = [Item(image: image, kind: "playlist")] }
      self.update(spotAtIndex: 1) { $0.items.insert(Item(title: user.displayName), at: 0) }
    }
  }
}

extension ProfileController: SpotsDelegate {

  func spotDidSelectItem(_ spot: Spotable, item: Item) {
    guard let urn = item.action else { return }
    Compass.navigate(to: urn)
  }
}
