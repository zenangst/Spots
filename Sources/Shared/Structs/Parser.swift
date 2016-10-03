/**
  A JSON to UI parser to produce components for SpotsController
 */
public struct Parser {

  /**
   - parameter json: A JSON dictionary of components and items
   - parameter key: The key that should be used for parsing JSON, defaults to `components`

   - returns: A collection of spotable objects
   */
  public static func parse(_ json: [String : AnyObject], key: String = "components") -> [Spotable] {
    var components: [Component] = parse(json, key: key)

    for (index, _) in components.enumerated() {
      components[index].index = index
    }

    return components.map { SpotFactory.resolve($0) }
  }

  /**
   - parameter json: A JSON dictionary of components and items
   - parameter key: The key that should be used for parsing JSON, defaults to `components`

   - returns: A collection of `Component`s
   */
  public static func parse(_ json: [String : AnyObject], key: String = "components") -> [Component] {
    guard let components = json[key] as? [[String : AnyObject]] else { return [] }

    return components.map { Component($0) }
  }

  /**
   - parameter json: A JSON dictionary of components and items

   - returns: A collection of spotable objects
   */
  public static func parse(_ json: [[String : AnyObject]]?) -> [Spotable] {
    guard let json = json else { return [] }

    return json.map {
      SpotFactory.resolve(Component($0))
    }
  }
}
