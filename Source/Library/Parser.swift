import UIKit
import Sugar

public struct Parser {

  public static func parse(json: JSONDictionary) -> [Spotable] {
    guard let components = json["components"] as? JSONArray else { return [] }
    var spots = [Spotable]()

    components.forEach { spots.append(SpotFactory.resolve(Component($0)))  }
    
    return spots
  }
}
