import Foundation
import Spots
import Compass

class AuthController: SpotsController, SpotsDelegate {

  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = UIColor.blackColor()
    self.container.backgroundColor = UIColor.blackColor()
    self.spotsDelegate = self
  }

  func spotDidSelectItem(spot: Spotable, item: ListItem) {
    guard let urn = item.action else { return }
    Compass.navigate(urn)
  }
}
