import Spots
import Compass

extension SpotsController: SpotsDelegate {

  public func spotDidSelectItem(spot: Spotable, item: ListItem) {
    guard let urn = item.action else { return }
    Compass.navigate(urn)
  }
}
