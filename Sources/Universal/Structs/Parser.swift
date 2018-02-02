import Foundation

/// A JSON to UI parser to produce components for Controller
public struct Parser {

  /// Parse JSON into a collection of components with key.
  ///
  /// - parameter json: A JSON dictionary of components and items.
  ///
  /// - returns: A collection of components
  @available(*, deprecated: 7.0, message: "Deprecated in favor for parseComponents with data")
  public static func parseComponents(json: [String : Any],
                                     key: String = "components",
                                     configuration: Configuration = .shared) -> [Component] {
    let components: [ComponentModel] = parseComponentModels(json: json, key: key)

    return components.map { model in
      Component(model: model, configuration: configuration)
    }
  }

  /// Parse JSON data into a collection of components with key.
  ///
  /// - parameter json: A JSON data of components and items.
  ///
  /// - returns: A collection of components
  public static func parseComponents(data: Data,
                                     key: String = "components",
                                     configuration: Configuration = .shared) -> [Component] {
    let components: [ComponentModel] = parseComponentModels(data: data, key: key)

    return components.map { model in
      Component(model: model, configuration: configuration)
    }
  }

  public static func parseComponents(modelsDictionary: [String: [ComponentModel]],
                                     key: String = "components",
                                     configuration: Configuration = .shared) -> [Component] {
    guard let models = modelsDictionary[key] else {
      return []
    }

    return parseComponents(models: models)
  }

  public static func parseComponents(models: [ComponentModel],
                                     configuration: Configuration = .shared) -> [Component] {
    return models.map { model in
      Component(model: model, configuration: configuration)
    }
  }

  /// Parse JSON into a collection of ComponentModels.
  ///
  /// - parameter json: A JSON dictionary of components and items.
  /// - parameter key: The key that should be used for parsing JSON, defaults to `components`.
  ///
  /// - returns: A collection of `ComponentModel`s
  public static func parseComponentModels(json: [String : Any],
                                          key: String = "components") -> [ComponentModel] {
    let jsonEncoder = JSONEncoder()

    guard let data = try? jsonEncoder.encode(json: json) else {
      return []
    }

    return parseComponentModels(data: data, key: key)
  }

  /// Parse JSON Data into a collection of ComponentModels.
  ///
  /// - parameter data: A JSON data of components and items.
  /// - parameter key: The key that should be used for parsing JSON, defaults to `components`.
  ///
  /// - returns: A collection of `ComponentModel`s
  public static func parseComponentModels(data: Data,
                                          key: String = "components") -> [ComponentModel] {
    let jsonDecoder = JSONDecoder()
    guard var payload = try? jsonDecoder.decode([String: [ComponentModel]].self, from: data) else {
      return []
    }

    guard var models = payload[key] else {
      return []
    }

    for index in models.indices {
      models[index].index = index
    }

    return models
  }
}
