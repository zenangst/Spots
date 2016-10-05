import Foundation
import Spots
import Compass
import Brick

class AuthController: SpotsController, SpotsDelegate {

  required init(spots: [Spotable]) {
    super.init(spots: spots)

    self.spotsDelegate = self
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  func spotDidSelectItem(_ spot: Spotable, item: Item) {
    guard let urn = item.action else { return }
    Compass.navigate(to: urn)
  }
}
