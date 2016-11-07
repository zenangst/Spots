#if os(OSX)
  import Foundation
#else
  import UIKit
#endif

import Tailor
import Brick

/// A component diff enum
///
/// - identifier: Indicates that the identifier changed
/// - kind:       Indicates that the kind changed
/// - span:       Indicates that the span changed
/// - header:     Indicates that the header changed
/// - meta:       Indicates that the meta changed
/// - items:      Indicates that the items changed
/// - new:        Indicates that the component is new
/// - removed:    Indicates that the component was removed
/// - none:       Indicates that nothing did change
public enum ComponentDiff {
  case identifier, kind, span, header, meta, items, new, removed, none
}

/// The Component struct is used to configure a Spotable object
public struct Component: Mappable, Equatable {

  /// An enum with all the string keys used in the view model
  public enum Key: String, StringConvertible {
    case Index
    case Identifier
    case Title
    case Header
    case Kind
    case Meta
    case Span
    case Items
    case Size
    case Width
    case Height

    public var string: String {
      return rawValue.lowercased()
    }
  }

  /// An enum for identifing the Component kind
  public enum Kind: String {
    /// The identifier for CarouselSpot
    case Carousel = "carousel"
    /// The identifier for GridSpot
    case Grid = "grid"
    /// The identifier for ListSpot
    case List = "list"
    /// The identifier for RowSpot
    case Row = "row"

    /// The lowercase raw value of the case
    public var string: String {
      return rawValue.lowercased()
    }
  }

  /// Identifier
  public var identifier: String?
  /// The index of the Item when appearing in a list, should be computed and continuously updated by the data source
  public var index: Int = 0
  /// The title for the component
  public var title: String = ""
  /// Determines which spotable component that should be used
  /// Default kinds are; list, grid and carousel
  public var kind: String = ""
  /// The header identifier
  public var header: String = ""
  /// Configures the span that should be used for items in one row
  /// Used by gridable components
  public var span: Double = 0
  /// A collection of view models
  public var items: [Item] = [Item]()
  /// The width and height of the component, usually calculated and updated by the UI component
  public var size: CGSize?
  /// A key-value dictionary for any additional information
  public var meta = [String : Any]()

  /// A dictionary representation of the component
  public var dictionary: [String : Any] {
    return dictionary()
  }

  /// A method that creates a dictionary representation of the Component
  ///
  /// - parameter amountOfItems: An optional Int that is used to limit the amount of items that should be transformed into JSON
  ///
  /// - returns: A dictionary representation of the Component
  public func dictionary(_ amountOfItems: Int? = nil) -> [String : Any] {
    var width: CGFloat = 0
    var height: CGFloat = 0

    if let size = size {
      width = size.width
      height = size.height
    }

    let JSONItems: [[String : Any]]

    if let amountOfItems = amountOfItems {
      JSONItems = Array(items[0..<min(amountOfItems, items.count)]).map { $0.dictionary }
    } else {
      JSONItems = items.map { $0.dictionary }
    }

    var JSONComponents: [String : Any] = [
      Key.Index.string : index,
      Key.Kind.string : kind,
      Key.Span.string : span,
      Key.Size.string : [
        Key.Width.string : width,
        Key.Height.string : height
      ],
      Key.Items.string: JSONItems,
      ]

    JSONComponents[Key.Identifier.string] = identifier

    if !title.isEmpty { JSONComponents[Key.Title.string] = title }
    if !header.isEmpty { JSONComponents[Key.Header.string] = header }
    if !meta.isEmpty { JSONComponents[Key.Meta.string] = meta }

    return JSONComponents
  }

  /// Initializes a component with a JSON dictionary and maps the keys of the dictionary to its corresponding values.
  ///
  /// - parameter map: A JSON key-value dictionary.
  ///
  /// - returns: An initialized component using JSON.
  public init(_ map: [String : Any]) {
    identifier = map.property("identifier")
    title     <- map.property("title")
    kind      <- map.property("kind")
    header    <- map.property("header")
    items     <- map.relations("items")
    meta      <- map.property("meta")

    if let span: Int = map.property("span") {
      self.span = Double(span)
    } else if let span: Float = map.property("span") {
      self.span = Double(span)
    } else {
      self.span <- map.property("span")
    }

    let width: Double = map.resolve(keyPath: "size.width") ?? 0.0
    let height: Double = map.resolve(keyPath: "size.height") ?? 0.0
    size = CGSize(width: width, height: height)
  }

  /// Initializes a component and configures it with the provided parameters
  ///
  /// - parameter identifier: A optional string
  /// - parameter title: The title for your UI component.
  /// - parameter header: Determines which header item that should be used for the component.
  /// - parameter kind: The type of Component that should be used.
  /// - parameter span: Configures the span that should be used for items in one row
  /// - parameter items: A collection of view models
  /// - parameter meta: A key-value dictionary for any additional information
  ///
  /// - returns: An initialized component
  public init(identifier: String? = nil,
              title: String = "",
              header: String = "",
              kind: String = "",
              span: Double = 0,
              items: [Item] = [],
              meta: [String : Any] = [:]) {
    self.identifier = identifier
    self.title = title
    self.kind = kind
    self.header = header
    self.span = span
    self.items = items
    self.meta = meta
  }

  // MARK: - Helpers

  /// A generic convenience method for resolving meta attributes
  ///
  /// - Parameter key: String
  /// - Parameter defaultValue: A generic value that works as a fallback if the key value object cannot be cast into the generic type
  ///
  /// - Returns: A generic value based on `defaultValue`, it falls back to `defaultValue` if type casting fails
  public func meta<T>(_ key: String, _ defaultValue: T) -> T {
    return meta[key] as? T ?? defaultValue
  }

  /// A convenience method for resolving meta attributes for CGFloats.
  ///
  /// - Parameter key: String.
  /// - Parameter defaultValue: A CGFloat value to be used as default if meta key is not found.
  ///
  /// - Returns: A generic value based on `defaultValue`, it falls back to `defaultValue` if type casting fails
  public func meta(_ key: String, _ defaultValue: CGFloat) -> CGFloat {
    if let doubleValue = meta[key] as? Double {
      return CGFloat(doubleValue)
    } else if let intValue = meta[key] as? Int {
      return CGFloat(intValue)
    }
    return defaultValue
  }


  /// A generic convenience method for resolving meta attributes
  ///
  /// - parameter key: String
  /// - parameter type: A generic type used for casting the meta property to a specific value or reference type
  /// - returns: An optional generic value based on `type`
  public func meta<T>(_ key: String, type: T.Type) -> T? {
    return meta[key] as? T
  }


  ///Compare two components
  ///
  /// - parameter component: A Component used for comparison
  ///
  /// - returns: A ComponentDiff value, see ComponentDiff for values.
  public func diff(component: Component) -> ComponentDiff {
    // Determine if the UI component is the same, used when Controller needs to replace the entire UI component
    if kind != component.kind { return .kind }
    // Determine if the unqiue identifier for the component changed
    if identifier != component.identifier { return .identifier }
    // Determine if the component span layout changed, this can be used to trigger layout related processes
    if span != component.span { return .span }
    // Determine if the header for the component has changed
    if header != component.header { return .header }
    // Check if meta data for the component changed, this can be up to the developer to decide what course of action to take.
    if !(meta as NSDictionary).isEqual(to: component.meta) { return .meta }
    // Check if the items have changed
    if !(items === component.items) { return .items }
    // Check children

    let lhsChildren = items.flatMap { $0.children }
    let rhsChildren = component.items.flatMap { $0.children }

    if !(lhsChildren as NSArray).isEqual(to: rhsChildren) {
      return .items
    }

    return .none
  }
}

// Compare a collection of view models

/// A collection of Component Equatable implementation
/// - parameter lhs: Left hand component
/// - parameter rhs: Right hand component
///
/// - returns: A boolean value, true if both Components are equal
public func == (lhs: [Component], rhs: [Component]) -> Bool {
  var equal = lhs.count == rhs.count

  if !equal { return false }

  for (index, item) in lhs.enumerated() {
    if item != rhs[index] { equal = false; break }
  }

  return equal
}


/// Compare two collections of Components to see if they are truly equal
///
/// - parameter lhs: Left hand component
/// - parameter rhs: Right hand component
///
/// - returns: A boolean value, true if both collections are equal
public func === (lhs: [Component], rhs: [Component]) -> Bool {
  var equal = lhs.count == rhs.count

  if !equal { return false }

  for (index, item) in lhs.enumerated() {
    if item !== rhs[index] { equal = false; break }
  }

  return equal
}


/// Check if to collection of components are not equal
///
/// - parameter lhs: Left hand component
/// - parameter rhs: Right hand component
///
/// - returns: A boolean value, true if both Components are no equal
public func != (lhs: [Component], rhs: [Component]) -> Bool {
  return !(lhs == rhs)
}


/// Check if to collection of components are truly not equal
///
/// - parameter lhs: Left hand component
/// - parameter rhs: Right hand component
///
/// - returns: A boolean value, true if both Components are no equal
public func !== (lhs: [Component], rhs: [Component]) -> Bool {
  return !(lhs === rhs)
}

/// Compare view models


/// Check if to components are equal
///
/// - parameter lhs: Left hand component
/// - parameter rhs: Right hand component
///
/// - returns: A boolean value, true if both Components are no equal
public func == (lhs: Component, rhs: Component) -> Bool {
  guard lhs.identifier == rhs.identifier else { return false }

  return lhs.title == rhs.title &&
    lhs.kind == rhs.kind &&
    lhs.span == rhs.span &&
    lhs.header == rhs.header &&
    (lhs.meta as NSDictionary).isEqual(rhs.meta as NSDictionary) &&
    lhs.items == rhs.items
}


/// Check if to components are truly equal
///
/// - parameter lhs: Left hand component
/// - parameter rhs: Right hand component
///
/// - returns: A boolean value, true if both Components are no equal
public func === (lhs: Component, rhs: Component) -> Bool {
  guard lhs.identifier == rhs.identifier else { return false }

  let lhsChildren = lhs.items.flatMap { $0.children }
  let rhsChildren = rhs.items.flatMap { $0.children }

  return lhs.title == rhs.title &&
    lhs.kind == rhs.kind &&
    lhs.span == rhs.span &&
    lhs.header == rhs.header &&
    (lhs.meta as NSDictionary).isEqual(rhs.meta as NSDictionary) &&
    (lhsChildren as NSArray).isEqual(to: rhsChildren) &&
    lhs.items === rhs.items
}


/// Check if to components are not equal
///
/// - parameter lhs: Left hand component
/// - parameter rhs: Right hand component
///
/// - returns: A boolean value, true if both Components are no equal
public func != (lhs: Component, rhs: Component) -> Bool {
  return !(lhs == rhs)
}


/// Check if to components are truly not equal
///
/// - parameter lhs: Left hand component
/// - parameter rhs: Right hand component
///
/// - returns: A boolean value, true if both Components are no equal
public func !== (lhs: Component, rhs: Component) -> Bool {
  return !(lhs === rhs)
}
