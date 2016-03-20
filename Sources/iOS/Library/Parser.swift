import Foundation
import Sugar

public struct Parser {

  public static func parse(json: JSONDictionary) -> [Spotable] {
    guard let components = json["components"] as? JSONArray else { return [] }

    return components.map {
      SpotFactory.resolve(Component($0))
    }
  }
}
