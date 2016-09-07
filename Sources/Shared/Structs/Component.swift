#if os(iOS)
  import UIKit
#else
  import Foundation
#endif

import Tailor
import Sugar
import Brick

public enum ComponentDiff {
  case Identifier, Kind, Span, Header, Meta, Items, New, Removed, None
}

/// The Component struct is used to configure a Spotable object
public struct Component: Mappable, Equatable {

  /**
   An enum with all the string keys used in the view model
   */
  public enum Key: String {
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

    var string: String {
      return rawValue.lowercaseString
    }
  }

  public enum Kind: String {
    case Carousel = "carousel"
    case Grid = "grid"
    case List = "list"

    public var string: String {
      return rawValue.lowercaseString
    }
  }

  // Identifier
  public var identifier: String?
  /// The index of the ViewModel when appearing in a list, should be computed and continuously updated by the data source
  public var index = 0
  /// The title for the component
  public var title = ""
  /// Determines which spotable component that should be used
  /// Default kinds are; list, grid and carousel
  public var kind = ""
  /// The header identifier
  public var header = ""
  /// Configures the span that should be used for items in one row
  /// Used by gridable components
  public var span: CGFloat = 0
  /// A collection of view models
  public var items = [ViewModel]()
  /// The width and height of the component, usually calculated and updated by the UI component
  public var size: CGSize?
  /// A key-value dictionary for any additional information
  public var meta = [String : AnyObject]()

  /// A dictionary representation of the component
  public var dictionary: JSONDictionary {
    return dictionary()
  }

  public func dictionary(amountOfItems: Int? = nil) -> JSONDictionary {
    var width: CGFloat = 0
    var height: CGFloat = 0

    if let size = size {
      width = size.width
      height = size.height
    }

    let JSONItems: [JSONDictionary]

    if let amountOfItems = amountOfItems {
      JSONItems = Array(items[0..<min(amountOfItems, items.count)]).map { $0.dictionary }
    } else {
      JSONItems = items.map { $0.dictionary }
    }

    var JSONComponents: JSONDictionary = [
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

  /**
   Initializes a component with a JSON dictionary and maps the keys of the dictionary to its corresponding values.

   - Parameter map: A JSON key-value dictionary
   */
  public init(_ map: JSONDictionary) {
    identifier = map.property(.Identifier)
    title <- map.property(.Title)
    kind  <- map.property(.Kind)
    header  <- map.property(.Header)
    span  <- map.property(.Span)
    items <- map.relations(.Items)
    meta  <- map.property(.Meta)

    if let size = map["size"] as? JSONDictionary {
      self.size = CGSize(width: size.property(Key.Width.string) ?? 0.0,
                         height: size.property(Key.Height.string) ?? 0.0)
    }
  }

  /**
   Initializes a component and configures it with the provided parameters

   - Parameter title: The title for your UI component.
   - Parameter kind: The type of Component that should be used.
   - Parameter span: Configures the span that should be used for items in one row
   - Parameter items: A collection of view models
   - Parameter meta: A key-value dictionary for any additional information
   */
  public init(identifier: String? = nil,
              title: String = "",
              header: String = "",
              kind: String = "",
              span: CGFloat = 0,
              items: [ViewModel] = [],
              meta: [String : AnyObject] = [:]) {
    self.identifier = identifier
    self.title = title
    self.kind = kind
    self.header = header
    self.span = span
    self.items = items
    self.meta = meta
  }

  // MARK: - Helpers

  /**
   A generic convenience method for resolving meta attributes

   - Parameter key: String
   - Parameter defaultValue: A generic value that works as a fallback if the key value object cannot be cast into the generic type
   - Returns: A generic value based on `defaultValue`, it falls back to `defaultValue` if type casting fails
   */
  public func meta<T>(key: String, _ defaultValue: T) -> T {
    return meta[key] as? T ?? defaultValue
  }

  /**
   A generic convenience method for resolving meta attributes

   - Parameter key: String
   - Parameter type: A generic type used for casting the meta property to a specific value or reference type
   - Returns: An optional generic value based on `type`
   */
  public func meta<T>(key: String, type: T.Type) -> T? {
    return meta[key] as? T
  }

  /**
   Compare two components

   - parameter component: A Component used for comparison

   - returns: A ComponentDiff value, see ComponentDiff for values.
   */
  public func diff(component component: Component) -> ComponentDiff {
    // Determine if the UI component is the same, used when SpotsController needs to replace the entire UI component
    if kind != component.kind { return .Kind }
    // Determine if the unqiue identifier for the component changed
    if identifier != component.identifier { return .Identifier }
    // Determine if the component span layout changed, this can be used to trigger layout related processes
    if span != component.span { return .Span }
    // Determine if the header for the component has changed
    if header != component.header { return .Header }
    // Check if meta data for the component changed, this can be up to the developer to decide what course of action to take.
    if !(meta as NSDictionary).isEqualToDictionary(component.meta) { return .Meta }
    // Check if the items have changed
    if !(items == component.items) { return .Items }
    // Check children

    let lhsChildren = items.flatMap { $0.children }
    let rhsChildren = component.items.flatMap { $0.children }

    if !(lhsChildren as NSArray).isEqualToArray(rhsChildren) {
      return .Items
    }

    return .None
  }
}

// Compare a collection of view models

/**
 A collection of Component Equatable implementation
 - Parameter lhs: Left hand component
 - Parameter rhs: Right hand component
 - Returns: A boolean value, true if both Components are equal
 */

public func == (lhs: [Component], rhs: [Component]) -> Bool {
  var equal = lhs.count == rhs.count

  if !equal { return false }

  for (index, item) in lhs.enumerate() {
    if item != rhs[index] { equal = false; break }
  }

  return equal
}

public func === (lhs: [Component], rhs: [Component]) -> Bool {
  var equal = lhs.count == rhs.count

  if !equal { return false }

  for (index, item) in lhs.enumerate() {
    if item !== rhs[index] { equal = false; break }
  }

  return equal
}

/**
 Check if to collection of components are not equal
 - Parameter lhs: Left hand component
 - Parameter rhs: Right hand component
 - Returns: A boolean value, true if both Components are no equal
 */
public func != (lhs: [Component], rhs: [Component]) -> Bool {
  return !(lhs == rhs)
}

/**
 Check if to collection of components are truly not equal
 - Parameter lhs: Left hand component
 - Parameter rhs: Right hand component
 - Returns: A boolean value, true if both Components are no equal
 */
public func !== (lhs: [Component], rhs: [Component]) -> Bool {
  return !(lhs === rhs)
}

/// Compare view models

/**
 Check if to components are equal
 - Parameter lhs: Left hand component
 - Parameter rhs: Right hand component
 - Returns: A boolean value, true if both Components are no equal
 */
public func == (lhs: Component, rhs: Component) -> Bool {
  guard lhs.identifier == rhs.identifier else { return false }

  return lhs.title == rhs.title &&
    lhs.kind == rhs.kind &&
    lhs.span == rhs.span &&
    lhs.header == rhs.header &&
    (lhs.meta as NSDictionary).isEqual(rhs.meta as NSDictionary) &&
    lhs.items == rhs.items
}

/**
 Check if to components are truly equal
 - Parameter lhs: Left hand component
 - Parameter rhs: Right hand component
 - Returns: A boolean value, true if both Components are no equal
 */
public func === (lhs: Component, rhs: Component) -> Bool {
  guard lhs.identifier == rhs.identifier else { return false }

  let lhsChildren = lhs.items.flatMap { $0.children }
  let rhsChildren = rhs.items.flatMap { $0.children }

  return lhs.title == rhs.title &&
    lhs.kind == rhs.kind &&
    lhs.span == rhs.span &&
    lhs.header == rhs.header &&
    (lhs.meta as NSDictionary).isEqual(rhs.meta as NSDictionary) &&
    (lhsChildren as NSArray).isEqualToArray(rhsChildren) &&
    lhs.items === rhs.items
}

/**
 Check if to components are not equal
 - Parameter lhs: Left hand component
 - Parameter rhs: Right hand component
 - Returns: A boolean value, true if both Components are no equal
 */
public func != (lhs: Component, rhs: Component) -> Bool {
  return !(lhs == rhs)
}

/**
 Check if to components are truly not equal
 - Parameter lhs: Left hand component
 - Parameter rhs: Right hand component
 - Returns: A boolean value, true if both Components are no equal
 */
public func !== (lhs: Component, rhs: Component) -> Bool {
  return !(lhs === rhs)
}
