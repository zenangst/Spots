import Spots
import Compass
import Keychain

class ProfileController: SpotsController {

  let accessToken = Keychain.password(forAccount: keychainAccount)

  convenience init(title: String) {
    let gridSpot = GridSpot().then {
      $0.component.span = 1
    }
    let listSpot = ListSpot().then {
      $0.headerHeight = 44
      $0.component.title = "User information"
      $0.items = [ListItem(title: "Logout", action: "logout")]
    }

    self.init(spots: [gridSpot, listSpot])
    self.title = title
    self.spotsDelegate = self

    refreshData()
  }

  func refreshData() {

    SPTUser.requestUser(username, withAccessToken: accessToken) { (error, object) -> Void in
      guard let user = object as? SPTUser else { return }
      let image = user.largestImage.imageURL.absoluteString

      self.update {
        let item = ListItem(kind: "playlist", image: image)
        $0.items = [item]
      }

      self.update(spotAtIndex: 1) {
        $0.items.insert(ListItem(title: user.displayName), atIndex: 0)
      }
    }
  }
}

extension ProfileController: SpotsDelegate {

  func spotDidSelectItem(spot: Spotable, item: ListItem) {
    guard let urn = item.action else { return }
    Compass.navigate(urn)
  }
}
