import UIKit
import Sugar

enum ContainerType: String {
  case
  Carousel = "carousel",
  Grid = "grid",
  List = "list"
}

struct Parser {

  static func parse(json: JSONDictionary) -> [Spotable] {
    guard let components = json["components"] as? JSONArray else { return [] }
    var spots = [Spotable]()

    for json in components {
      let component = Component(json)
      switch ContainerType(rawValue: component.type) {
      case .Carousel?:
        spots.append(CarouselSpot(component: component))
      case .Grid?:
        spots.append(GridSpot(component: component))
      case .List?:
        spots.append(ListSpot(component: component))
      default:
        break
      }
    }
    
    return spots
  }
}
