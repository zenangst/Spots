/// A JSON to UI parser to produce components for Controller
public struct Parser {

  /// Parse JSON into a collection of Component objects with key.
  ///
  /// - parameter json: A JSON dictionary of components and items.
  /// - parameter key: The key that should be used for parsing JSON, defaults to `components`.
  ///
  /// - returns: A collection of components
  public static func parse(_ json: [String : Any], key: String = "components") -> [Component] {
    var components: [ComponentModel] = parse(json, key: key)

    for (index, _) in components.enumerated() {
      components[index].index = index
    }

    return components.map {
      Factory.resolve(model: $0)
    }
  }

  /// Parse JSON into a collection of ComponentModels.
  ///
  /// - parameter json: A JSON dictionary of components and items.
  /// - parameter key: The key that should be used for parsing JSON, defaults to `components`.
  ///
  /// - returns: A collection of `ComponentModel`s
  public static func parse(_ json: [String : Any], key: String = "components") -> [ComponentModel] {
    guard let payloads = json[key] as? [[String : Any]] else { return [] }

    var models = [ComponentModel]()

    for (index, payload) in payloads.enumerated() {
      var model = ComponentModel(payload)
      model.index = index
      models.append(model)
    }

    return models
  }

  /// Parse JSON into a collection of ComponentModels.
  ///
  /// - parameter json: A JSON dictionary of components and items.
  /// - parameter key: The key that should be used for parsing JSON, defaults to `components`.
  ///
  /// - returns: A collection of `ComponentModel`s
  public static func parse(_ json: [String : Any]?, key: String = "components") -> [ComponentModel] {
    guard let payload = json else { return [] }

    return Parser.parse(payload)
  }

  /// Parse JSON into a collection of Component objects.
  ///
  /// - parameter json: A JSON dictionary of components and items.
  ///
  /// - returns: A collection of components
  public static func parse(_ json: [[String : Any]]?) -> [Component] {
    guard let json = json else { return [] }

    return json.map {
      Factory.resolve(model: ComponentModel($0))
    }
  }

  public static func parse(_ models: [ComponentModel]) -> [Component] {
    return models.map {
      Factory.resolve(model: $0)
    }
  }

  /// Parse view model children into Component objects
  /// - parameter item: A view model with children
  ///
  ///  - returns: A collection of Component objects
  public static func parse(_ item: Item) -> [Component] {
    let components: [Component] = Parser.parse(item.children)
    return components
  }
}
