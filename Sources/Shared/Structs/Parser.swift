/// A JSON to UI parser to produce components for Controller
public struct Parser {

  /// Parse JSON into a collection of components with key.
  ///
  /// - parameter json: A JSON dictionary of components and items.
  /// - parameter key: The key that should be used for parsing JSON, defaults to `components`.
  ///
  /// - returns: A collection of components
  public static func parse(_ json: [String : Any], key: String = "components", configuration: Configuration = .shared) -> [Component] {
    var components: [ComponentModel] = parse(json, key: key)

    for element in components.indices {
      components[element].index = element
    }

    return components.map { model in
      Component(model: model, configuration: configuration)
    }
  }

  /// Parse JSON into a collection of ComponentModels.
  ///
  /// - parameter json: A JSON dictionary of components and items.
  /// - parameter key: The key that should be used for parsing JSON, defaults to `components`.
  ///
  /// - returns: A collection of `ComponentModel`s
  public static func parse(_ json: [String : Any], key: String = "components", configuration: Configuration = .shared) -> [ComponentModel] {
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
  public static func parse(_ json: [String : Any]?, key: String = "components", configuration: Configuration = .shared) -> [ComponentModel] {
    guard let payload = json else { return [] }

    return Parser.parse(payload)
  }

  /// Parse JSON into a collection of components.
  ///
  /// - parameter json: A JSON dictionary of components and items.
  ///
  /// - returns: A collection of components
  public static func parse(_ json: [[String : Any]]?, configuration: Configuration = .shared) -> [Component] {
    guard let json = json else { return [] }

    return json.map { model in
      Component(model: ComponentModel(model), configuration: configuration)
    }
  }

  public static func parse(_ models: [ComponentModel], configuration: Configuration = .shared) -> [Component] {
    return models.map { model in
      Component(model: model, configuration: configuration)
    }
  }
}
