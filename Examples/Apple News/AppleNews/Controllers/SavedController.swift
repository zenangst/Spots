import Spots
import Fakery
import Sugar

class SavedController: SpotsController {

  static let faker = Faker()

  convenience init(title: String) {
    let component = Component()
    let feedSpot = FeedSpot(component: component)
    self.init(spots: [feedSpot], refreshable: false)

    self.title = title

    dispatch(queue: .Interactive) { [weak self] in
      let items = ForYouController.generateItems(0, to: 2)
      self?.updateSpotAtIndex(0, closure: { (spot) -> Spotable in
        spot.component.items = items
        return spot
      })
    }
  }
}
