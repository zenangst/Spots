import Foundation
import Spots
import Compass
import Brick

class AuthController: Controller, SpotsDelegate {

  required init(spots: [Spotable]) {
    super.init(spots: spots)

    self.delegate = self
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  func didSelect(item: Item, in spot: Spotable) {
    guard let urn = item.action else { return }
    Compass.navigate(to: urn)
  }
}
