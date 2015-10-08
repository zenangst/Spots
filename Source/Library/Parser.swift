import UIKit
import Sugar

struct Parser {

  static func parse(json: JSONDictionary) -> [Spotable] {
    guard let components = json["components"] as? JSONArray else { return [] }
    var spots = [Spotable]()

    for json in components {
      let component = Component(json)
      switch component.type {
      case "carousel":
        spots.append(CarouselSpot(component: component))
      case "list":
        spots.append(ListSpot(component: component))
      default:
        spots.append(GridSpot(component: component))
        break
      }
    }
    
    return spots
  }
}
