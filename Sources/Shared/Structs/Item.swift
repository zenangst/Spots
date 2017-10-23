#if os(iOS) || os(watchOS) || os(tvOS)
  import UIKit
#else
  import Foundation
#endif

import Tailor

/**
 A value type struct, it conforms to the Mappable protocol so that it can be instantiated with JSON
 */
public struct Item: Codable, Mappable, Indexable, DictionaryConvertible {

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
    case model
    case modelData
    case kind
    case action
    case meta
    case children
    case relations
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

  var model: ItemCodable?
  var modelData: NSData?

  /// A dictionary representation of the view model
  public var dictionary: [String : Any] {
    var dictionary: [String: Any] = [
      Key.index.string: index,
      Key.kind.string: kind,
      Key.size.string: [
        Key.width.string: Double(size.width),
        Key.height.string: Double(size.height)
      ]
    ]

    if !title.isEmpty { dictionary[Key.title.string] = title }
    if !subtitle.isEmpty { dictionary[Key.subtitle.string] = subtitle }
    if !text.isEmpty { dictionary[Key.text.string] = text }
    if !image.isEmpty { dictionary[Key.image.string] = image }
    if !meta.isEmpty { dictionary[Key.meta.string] = meta }

    if let identifier = identifier {
      dictionary[Key.identifier.string] = identifier
    }

    if let action = action {
      dictionary[Key.action.string] = action
    }

    if let model = model as? DictionaryConvertible {
      dictionary[Key.model.string] = model.dictionary
    }

    var relationItems = [String: [[String: Any]]]()

    relations.forEach { key, array in
      if relationItems[key] == nil { relationItems[key] = [[String: Any]]() }
      array.forEach { relationItems[key]?.append($0.dictionary) }
    }

    if !relationItems.isEmpty {
      dictionary[Key.relations.string] = relationItems
    }

    return dictionary
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: Item.Key.self)
    try container.encodeIfPresent(self.index, forKey: Item.Key.index)
    try container.encodeIfPresent(self.identifier, forKey: Item.Key.identifier)
    try container.encodeIfPresent(self.title, forKey: Item.Key.title)
    try container.encodeIfPresent(self.subtitle, forKey: Item.Key.subtitle)
    try container.encodeIfPresent(self.text, forKey: Item.Key.text)
    try container.encodeIfPresent(self.image, forKey: Item.Key.image)
    try container.encodeIfPresent(self.kind, forKey: Item.Key.kind)
    //try container.encodeIfPresent(self.size, forKey: Item.Key.size)

    if let dictionary = try? JSONSerialization.data(withJSONObject: dictionary,
                                               options: .prettyPrinted) {
      try container.encodeIfPresent(dictionary, forKey: Item.Key.meta)
    }

    try container.encodeIfPresent(self.relations, forKey: Item.Key.relations)

    var model = self.model

    let modelData = withUnsafePointer(to: &model) { pointer in
      NSData(bytes: pointer, length: MemoryLayout.size(ofValue: model))
    }

//    try container.encode(modelData, forKey: Item.Key.modelData)

    //try container.encodeIfPresent(self.model, forKey: Item.Key.model)
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Item.Key.self)
    self.index = try container.decodeIfPresent(Int.self, forKey: Item.Key.index) ?? 0
    self.identifier = try container.decodeIfPresent(Int.self, forKey: Item.Key.identifier)
    self.title = try container.decodeIfPresent(String.self, forKey: Item.Key.title) ?? ""
    self.subtitle = try container.decodeIfPresent(String.self, forKey: Item.Key.subtitle) ?? ""
    self.text = try container.decodeIfPresent(String.self, forKey: Item.Key.text) ?? ""
    self.image = try container.decodeIfPresent(String.self, forKey: Item.Key.image) ?? ""
    self.kind = try container.decodeIfPresent(String.self, forKey: Item.Key.kind) ?? ""
    self.action = try container.decodeIfPresent(String.self, forKey: Item.Key.action)
//    self.size = try container.decodeIfPresent(CGSize.self, forKey: Item.Key.size) ?? .zero
    self.meta = try container.decodeIfPresent([String: Any].self, forKey: Item.Key.meta) ?? [:]
    self.relations = try container.decodeIfPresent([String: [Item]].self, forKey: Item.Key.relations) ?? [:]
    self.modelData = try container.decodeIfPresent(Data.self, forKey: Item.Key.modelData) as! NSData


//    let data = try container.decode(Data.self, forKey: Item.Key.modelData)



//    let modelData = withUnsafePointer(to: &self.model) { pointer in
//      NSData(bytes: pointer, length: MemoryLayout.size(ofValue: self.model))
//    }



    //self.model = try container.decodeIfPresent(DictionaryConvertible.self, forKey: Item.Key.model)
  }

  // MARK: - Initialization

  /**
   Initialization a new instance of a Item and map it to a JSON dictionary

   - parameter map: A JSON dictionary
   */
  public init(_ map: [String : Any]) {
    index    <- map.int(Key.index.rawValue)
    identifier <- map.int(Key.identifier.rawValue)
    title    <- map.string(Key.title.rawValue)
    subtitle <- map.string(Key.subtitle.rawValue)
    text     <- map.string(Key.text.rawValue)
    image    <- map.string(Key.image.rawValue)
    kind     <- map.string(Key.kind.rawValue)
    action   = map.string(Key.action.rawValue)
    meta     <- map.property(Key.meta.rawValue)

    if let relation = map[.relations] as? [String : [Item]] {
      relations = relation
    }

    if let relations = map[.relations] as? [String : [[String : Any]]] {
      var newRelations = [String: [Item]]()
      relations.forEach { key, array in
        if newRelations[key] == nil { newRelations[key] = [Item]() }
        array.forEach { newRelations[key]?.append(Item($0)) }

        self.relations = newRelations
      }
    }

    let width: Double = map.resolve(keyPath: "size.width") ?? 0.0
    let height: Double = map.resolve(keyPath: "size.height") ?? 0.0
    size = CGSize(width: width, height: height)
  }

  /**
   Initialization a new instance of a Item and map it to a JSON dictionary

   - parameter title: The title string for the view model, defaults to empty string
   - parameter subtitle: The subtitle string for the view model, default to empty string
   - parameter image: Image name or URL as a string, default to empty string
   */
  public init(identifier: Int? = nil,
              title: String = "",
              subtitle: String = "",
              text: String = "",
              image: String = "",
              model: ItemCodable? = nil,
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
    self.model = model
    self.kind = kind.string
    self.action = action
    self.size = size
    self.meta = meta
    self.relations = relations
  }

  /**
   Initialization a new instance of a Item and map it to a JSON dictionary

   - parameter title: The title string for the view model, defaults to empty string
   - parameter subtitle: The subtitle string for the view model, default to empty string
   - parameter image: Image name or URL as a string, default to empty string
   */
  public init(identifier: Int? = nil,
              title: String = "",
              subtitle: String = "",
              text: String = "",
              image: String = "",
              model: ItemCodable? = nil,
              kind: StringConvertible = "",
              action: String? = nil,
              size: CGSize = CGSize(width: 0, height: 0),
              meta: Mappable,
              relations: [String : [Item]] = [:]) {
    self.init(identifier: identifier,
              title: title,
              subtitle: subtitle,
              text: text,
              image: image,
              model: model,
              kind: kind,
              action: action,
              size: size,
              meta: meta.metaProperties,
              relations: relations)
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
   A generic convenience method for resolving meta instance

   - returns: A generic meta instance based on `type`
   */
  public func metaInstance<T: Mappable>() -> T {
    return T(meta)
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
