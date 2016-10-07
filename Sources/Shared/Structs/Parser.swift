/// A JSON to UI parser to produce components for Controller
public struct Parser {

  /// Parse JSON into a collection of Spotable objects with key.
  ///
  /// - parameter json: A JSON dictionary of components and items.
  /// - parameter key: The key that should be used for parsing JSON, defaults to `components`.
  ///
  /// - returns: A collection of spotable objects
  public static func parse(_ json: [String : Any], key: String = "components") -> [Spotable] {
    var components: [Component] = parse(json, key: key)

    for (index, _) in components.enumerated() {
      components[index].index = index
    }

    return components.map { SpotFactory.resolve(component: $0) }
  }

  /// Parse JSON into a collection of Components.
  ///
  /// - parameter json: A JSON dictionary of components and items.
  /// - parameter key: The key that should be used for parsing JSON, defaults to `components`.
  ///
  /// - returns: A collection of `Component`s
  public static func parse(_ json: [String : Any], key: String = "components") -> [Component] {
    guard let components = json[key] as? [[String : Any]] else { return [] }

    return components.map { Component($0) }
  }

  /// Parse JSON into a collection of Spotable objects.
  ///
  /// - parameter json: A JSON dictionary of components and items.
  ///
  /// - returns: A collection of spotable objects
  public static func parse(_ json: [[String : Any]]?) -> [Spotable] {
    guard let json = json else { return [] }

    return json.map {
      SpotFactory.resolve(component: Component($0))
    }
  }
}
