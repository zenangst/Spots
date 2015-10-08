import UIKit
import Sugar

public struct Parser {

  public static func parse(json: JSONDictionary) -> [Spotable] {
    guard let components = json["components"] as? JSONArray else { return [] }
    var spots = [Spotable]()

    for json in components {
      let component = Component(json)
      spots.append(SpotFactory.resolve(component))
    }
    
    return spots
  }
}
