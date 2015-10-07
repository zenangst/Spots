import UIKit
import Sugar

enum ContainerType: String {
  case
  List = "list",
  Grid = "grid"
}

struct Parser {

  static func parse(json: JSONDictionary) -> [Spotable] {
    guard let components = json["components"] as? JSONArray else { return [] }
    var spots = [Spotable]()

    for json in components {
      let component = Component(json)
      switch ContainerType(rawValue: component.type) {
      case .List?:
        spots.append(ListSpot(component: component))
      case .Grid?:
        spots.append(GridSpot(component: component))
      default:
        break
      }
    }
    
    return spots
  }
}
