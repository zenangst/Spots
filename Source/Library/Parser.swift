import UIKit
import Sugar

enum ContainerType: String {
  case List = "list"
}

struct Parser {

  static func parse(json: JSONDictionary) -> [ComponentContainer] {
    guard let components = json["components"] as? JSONArray else { return [ComponentContainer]() }
    var containers = [ComponentContainer]()

    for json in components {
      let component = Component(json)
      switch ContainerType(rawValue: component.type) {
      case .List?:
        containers.append(ListComponent(component: component))
      default:
        break
      }
    }
    
    return containers
  }
}
