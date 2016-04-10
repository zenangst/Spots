import Foundation
import Spots
import Compass
import Brick

class AuthController: SpotsController, SpotsDelegate {

  override func viewDidLoad() {
    super.viewDidLoad()

    self.spotsDelegate = self
  }

  func spotDidSelectItem(spot: Spotable, item: ViewModel) {
    guard let urn = item.action else { return }
    Compass.navigate(urn)
  }
}
