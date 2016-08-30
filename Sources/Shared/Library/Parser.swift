import Sugar

/**
  A JSON to UI parser to produce components for SpotsController
 */
public struct Parser {

  /**
   - Parameter json: A JSON dictionary of components and items
   - Returns: A collection of spotable objects
   */
  public static func parse(json: JSONDictionary, key: String = "components") -> [Spotable] {
    guard let components = json[key] as? JSONArray else { return [] }

    return components.map {
      SpotFactory.resolve(Component($0))
    }
  }

  public static func parse(json: JSONArray?) -> [Spotable] {
    guard let json = json else { return [] }

    return json.map {
      SpotFactory.resolve(Component($0))
    }
  }
}
