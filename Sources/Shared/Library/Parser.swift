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
    var components: [Component] = parse(json, key: key)
    for (index, component) in components.enumerate() {
      components[index].index = index
    }

    return components.map { SpotFactory.resolve($0) }
  }

  public static func parse(json: JSONDictionary, key: String = "components") -> [Component] {
    guard let components = json[key] as? JSONArray else { return [] }

    return components.map { Component($0) }
  }

  public static func parse(json: JSONArray?) -> [Spotable] {
    guard let json = json else { return [] }

    return json.map {
      SpotFactory.resolve(Component($0))
    }
  }
}
