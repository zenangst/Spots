#if os(iOS) || os(watchOS) || os(tvOS)
  import UIKit
#else
  import Foundation
#endif

/**
 A value type struct, it conforms to the Mappable protocol so that it can be instantiated with JSON
 */
public struct Item: Codable, Indexable {
  /**
   An enum with all the string keys used in the view model
   */
  public enum Key: String, CodingKey {
    case index
    case identifier
    case title
    case subtitle
    case text
    case image
    case kind
    case action
    case meta
    case relations
    case model
    case size
    case width
    case height

    var string: String {
      return rawValue.lowercased()
    }
  }

  /// The index of the Item when appearing in a list, should be computed and continuously updated by the data source
  public var index: Int = 0
  /// An optional identifier for your data
  public var identifier: Int?
  /// The main representation of the Item
  public var title: String = ""
  /// Supplementary information to the Item
  public var subtitle: String = ""
  /// An Optional text property for a more in-depth description of your Item
  public var text: String = ""
  /// A visual representation of the Item, usually a string URL or image name
  public var image: String = ""
  /// Determines what kind of UI should be used to represent the Item
  public var kind: String = ""
  /// A string representation of what should happen when a Item is tapped, usually a URN or URL
  public var action: String?
  /// The width and height of the view model, usually calculated and updated by the UI component
  public var size = CGSize(width: 0, height: 0)
  /// A key-value dictionary for any additional information
  public var meta = [String: Any]()
  /// A key-value dictionary for related view models
  public var relations = [String: [Item]]()
  /// An optional Codable model
  var model: ItemCodable?

  // MARK: - Initialization

  /**
   Initialization a new instance of a Item
   - parameter title: The title string for the view model, defaults to empty string
   - parameter subtitle: The subtitle string for the view model, default to empty string
   - parameter image: Image name or URL as a string, default to empty string
   */
  public init(identifier: Int? = nil,
              title: String = "",
              subtitle: String = "",
              text: String = "",
              image: String = "",
              kind: StringConvertible = "",
              action: String? = nil,
              size: CGSize = CGSize(width: 0, height: 0),
              meta: [String : Any] = [:],
              relations: [String : [Item]] = [:]) {
    self.identifier = identifier
    self.title = title
    self.subtitle = subtitle
    self.text = text
    self.image = image
    self.kind = kind.string
    self.action = action
    self.size = size
    self.meta = meta
    self.relations = relations
  }

  /**
   Initialization a new instance of a Item

   - parameter title: The title string for the view model, defaults to empty string
   - parameter subtitle: The subtitle string for the view model, default to empty string
   - parameter image: Image name or URL as a string, default to empty string
   */
  public init<T: ItemModel>(identifier: Int? = nil,
                            title: String = "",
                            subtitle: String = "",
                            text: String = "",
                            image: String = "",
                            model: T? = nil,
                            kind: StringConvertible = "",
                            action: String? = nil,
                            size: CGSize = CGSize(width: 0, height: 0),
                            meta: [String : Any] = [:],
                            relations: [String : [Item]] = [:]) {
    self.init(identifier: identifier,
              title: title,
              subtitle: subtitle,
              text: text,
              image: image,
              kind: kind,
              action: action,
              size: size,
              meta: meta,
              relations: relations)
    self.model = model
  }

  // MARK: - Codable

  /// Initialize with a decoder.
  ///
  /// - Parameter decoder: A decoder that can decode values into in-memory representations.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Item.Key.self)
    self.index = try container.decodeIfPresent(Int.self, forKey: .index) ?? 0
    self.identifier = try container.decodeIfPresent(Int.self, forKey: .identifier)
    self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
    self.subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle) ?? ""
    self.text = try container.decodeIfPresent(String.self, forKey: .text) ?? ""
    self.image = try container.decodeIfPresent(String.self, forKey: .image) ?? ""
    self.kind = try container.decodeIfPresent(String.self, forKey: .kind) ?? ""
    self.action = try container.decodeIfPresent(String.self, forKey: .action)
    self.size = try container.decodeIfPresent(CGSize.self, forKey: .size) ?? .zero
    self.meta = container.decodeJsonDictionaryIfPresent(forKey: .meta) ?? [:]
    self.relations = try container.decodeIfPresent([String: [Item]].self, forKey: .relations) ?? [:]
    self.model = try container.decodeIfPresent(forKey: .model, kind: kind)
  }

  /// Encode the struct into data.
  ///
  /// - Parameter encoder: An encoder that can encode the struct into data.
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: Item.Key.self)
    try container.encodeIfPresent(index, forKey: .index)
    try container.encodeIfPresent(identifier, forKey: .identifier)
    try container.encodeIfPresent(title, forKey: .title)
    try container.encodeIfPresent(subtitle, forKey: .subtitle)
    try container.encodeIfPresent(text, forKey: .text)
    try container.encodeIfPresent(image, forKey: .image)
    try container.encodeIfPresent(kind, forKey: .kind)
    try container.encodeIfPresent(action, forKey: .action)
    try container.encodeIfPresent(size, forKey: .size)
    try container.encodeIfPresent(relations, forKey: .relations)

    container.encode(jsonDictionary: meta, forKey: .meta)
    try container.encodeIfPresent(model: model, forKey: .model, kind: kind)
  }

  // MARK: - Helpers

  /**
   A generic convenience method for resolving meta attributes

   - parameter key: String
   - parameter defaultValue: A generic value that works as a fallback if the key value object cannot be cast into the generic type

   - returns: A generic value based on `defaultValue`, it falls back to `defaultValue` if type casting fails
   */
  public func meta<T>(_ key: String, _ defaultValue: T) -> T {
    return meta[key] as? T ?? defaultValue
  }

  /**
   A generic convenience method for resolving meta attributes

   - parameter key: String
   - parameter type: A generic type used for casting the meta property to a specific value or reference type

   - returns: An optional generic value based on `type`
   */
  public func meta<T>(_ key: String, type: T.Type) -> T? {
    return meta[key] as? T
  }

  /**
   A generic convenience method for resolving a model

   - returns: A generic model based on `type`
   */
  public func resolveModel<T: ItemModel>() -> T? {
    return model as? T
  }

  /**
   A generic convenience method for updating a model
   */
  public mutating func update<T: ItemModel>(model: T) {
    self.model = model
  }

  /**
   A convenience lookup method for resolving view model relations

   - parameter key: String
   - parameter index: The index of the object inside of `self.relations`
   */
  public func relation(_ key: String, _ index: Int) -> Item? {
    if let items = relations[key], index < items.count {
      return items[index]
    } else {
      return nil
    }
  }

  /**
   A method for mutating the kind of a view model

   - parameter kind: A StringConvertible object
   */
  public mutating func update(kind: StringConvertible) {
    self.kind = kind.string
  }

  /**
   Check if Item's are truly equal by including size and index in comparison

   - parameter lhs: Left hand Item
   - parameter rhs: Right hand Item

   - returns: A boolean value, true if both Item are equal
   */
  public func compareItemIncludingIndex(_ rhs: Item) -> Bool {
    let lhs = self
    let indexEqual = lhs.index == rhs.index
    let trulyEqual = lhs === rhs
    return indexEqual && trulyEqual
  }
}

/**
 A collection of Item Equatable implementation
 - parameter lhs: Left hand collection of Items
 - parameter rhs: Right hand collection of Items
 - returns: A boolean value, true if both Item are equal
 */
public func == (lhs: [Item], rhs: [Item]) -> Bool {
  var equal = lhs.count == rhs.count

  if !equal {
    return false
  }

  for (index, item) in lhs.enumerated() where item != rhs[index] {
    equal = false
    break
  }

  return equal
}

/**
 A collection of Item Equatable implementation to see if they are truly equal
 - parameter lhs: Left hand collection of Items
 - parameter rhs: Right hand collection of Items
 - returns: A boolean value, true if both Item are equal
 */
public func === (lhs: [Item], rhs: [Item]) -> Bool {
  var equal = lhs.count == rhs.count

  if !equal {
    return false
  }

  for (index, item) in lhs.enumerated() where !(item === rhs[index]) {
    equal = false
    break
  }

  return equal
}

/**
 Item Equatable implementation
 - parameter lhs: Left hand Item
 - parameter rhs: Right hand Item

 - returns: A boolean value, true if both Item are equal
 */
public func == (lhs: Item, rhs: Item) -> Bool {
  var modelsAreEqual: Bool = true
  if let lhsModel = lhs.model {
    if let rhsModel = rhs.model {
      modelsAreEqual = lhsModel == rhsModel
    } else {
      modelsAreEqual = false
    }
  }

  return lhs.identifier == rhs.identifier &&
    lhs.title == rhs.title &&
    lhs.subtitle == rhs.subtitle &&
    lhs.text == rhs.text &&
    lhs.image == rhs.image &&
    modelsAreEqual &&
    lhs.kind == rhs.kind &&
    lhs.action == rhs.action &&
    (lhs.meta as NSDictionary).isEqual(to: rhs.meta) &&
    compareRelations(lhs, rhs)
}

/**
 Item Equatable implementation
 - parameter lhs: Left hand Item
 - parameter rhs: Right hand Item

 - returns: A boolean value, true if both Item are not equal
 */
public func != (lhs: [Item], rhs: [Item]) -> Bool {
  return !(lhs == rhs)
}

/**
 Check if Item's are truly equal by including size in comparison

 - parameter lhs: Left hand Item
 - parameter rhs: Right hand Item

 - returns: A boolean value, true if both Item are equal
 */
public func === (lhs: Item, rhs: Item) -> Bool {
  var modelsAreEqual: Bool = true
  if let lhsModel = lhs.model {
    if let rhsModel = rhs.model {
      modelsAreEqual = lhsModel == rhsModel
    } else {
      modelsAreEqual = false
    }
  }

  let equal = lhs.identifier == rhs.identifier &&
    lhs.title == rhs.title &&
    lhs.subtitle == rhs.subtitle &&
    lhs.text == rhs.text &&
    lhs.image == rhs.image &&
    modelsAreEqual &&
    lhs.kind == rhs.kind &&
    lhs.action == rhs.action &&
    lhs.size == rhs.size &&
    (lhs.meta as NSDictionary).isEqual(to: rhs.meta) &&
    compareRelations(lhs, rhs)

  return equal
}

/**
 A collection of Item Equatable implementation to see if they are truly not equal
 - parameter lhs: Left hand collection of Items
 - parameter rhs: Right hand collection of Items
 - returns: A boolean value, true if both Item are not equal
 */
public func !== (lhs: [Item], rhs: [Item]) -> Bool {
  return !(lhs === rhs)
}

/**
 A reverse Equatable implementation for comparing Item's
 - parameter lhs: Left hand Item
 - parameter rhs: Right hand Item

 - returns: A boolean value, false if both Item are equal
 */
public func != (lhs: Item, rhs: Item) -> Bool {
  return !(lhs == rhs)
}

func compareRelations(_ lhs: Item, _ rhs: Item) -> Bool {
  guard lhs.relations.count == rhs.relations.count else {
    return false
  }

  var equal = true

  for (key, value) in lhs.relations {
    guard let rightValue = rhs.relations[key], value == rightValue
      else {
        equal = false
        break
    }
  }

  return equal
}
