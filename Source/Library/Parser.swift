import UIKit
import Sugar

struct Parser {

  static func parse(json: JSONDictionary) -> [Spotable] {
    guard let components = json["components"] as? JSONArray else { return [] }
    var spots = [Spotable]()

    for json in components {
      let component = Component(json)
      spots.append(SpotFactory.resolve(component))
    }
    
    return spots
  }
}
