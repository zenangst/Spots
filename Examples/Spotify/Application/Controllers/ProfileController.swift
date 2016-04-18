import Spots
import Compass
import Keychain
import Brick

class ProfileController: SpotsController {

  let accessToken = Keychain.password(forAccount: keychainAccount)

  convenience init(title: String) {
    let gridSpot = GridSpot().then {
      $0.component.span = 1
    }

    let listSpot = ListSpot().then {
      $0.component.meta["headerHeight"] = 44
      $0.component.title = "User information"
      $0.items = [ViewModel(title: "Logout", action: "logout")]
    }

    self.init(spots: [gridSpot, listSpot])
    self.title = title
    self.spotsDelegate = self

    refreshData()
  }

  func refreshData() {
    SPTUser.requestUser(username, withAccessToken: accessToken) { (error, object) -> Void in
      guard let user = object as? SPTUser where user.largestImage != nil else { return }
      let image = user.largestImage.imageURL.absoluteString

      self.update { $0.items = [ViewModel(kind: "playlist", image: image)] }
      self.update(spotAtIndex: 1) { $0.items.insert(ViewModel(title: user.displayName), atIndex: 0) }
    }
  }
}

extension ProfileController: SpotsDelegate {

  func spotDidSelectItem(spot: Spotable, item: ViewModel) {
    guard let urn = item.action else { return }
    Compass.navigate(urn)
  }
}
