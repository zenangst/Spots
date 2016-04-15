import Foundation
import Sugar

public struct Parser {

  /**
   - Parameter json: A JSON dictionary of components and items
   - Returns: A collection of spotable objects
   */
  public static func parse(json: JSONDictionary) -> [Spotable] {
    guard let components = json["components"] as? JSONArray else { return [] }

    return components.map {
      SpotFactory.resolve(Component($0))
    }
  }
}
