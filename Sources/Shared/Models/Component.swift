#if os(iOS)
  import UIKit
#else
  import Foundation
#endif

import Tailor
import Sugar
import Brick

/// The Component struct is used to configure a Spotable object
public struct Component: Mappable {
  /// The index of the ViewModel when appearing in a list, should be computed and continuously updated by the data source
  public var index = 0
  /// The title for the component
  public var title = ""
  /// Determines which spotable component that should be used
  /// Default kinds are; list, grid and carousel
  public var kind = ""
  /// Configures the span that should be used for items in one row
  /// Used by gridable components
  public var span: CGFloat = 0
  /// A collection of view models
  public var items = [ViewModel]()
  /// The width and height of the component, usually calculated and updated by the UI component
  public var size: CGSize?
  /// A key-value dictionary for any additional information
  public var meta = [String : AnyObject]()

  /**
   Initializes a component with a JSON dictionary and maps the keys of the dictionary to its corresponding values.

   - Parameter map: A JSON key-value dictionary
   */
  public init(_ map: JSONDictionary) {
    title <- map.property("title")
    kind  <- map.property("type")
    span  <- map.property("span")
    items <- map.relations("items")
    meta  <- map.property("meta")
  }

  /**
   Initializes a component and configures it with the provided parameters

   - Parameter title: The title for your UI component.
   - Parameter kind: The type of Component that should be used.
   - Parameter span: Configures the span that should be used for items in one row
   - Parameter items: A collection of view models
   - Parameter meta: A key-value dictionary for any additional information
   */
  public init(title: String = "", kind: String = "", span: CGFloat = 0, items: [ViewModel] = [], meta: [String : AnyObject] = [:]) {
    self.title = title
    self.kind = kind
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
}

/**
 A collection of Component Equatable implementation
 - Parameter lhs: Left hand component
 - Parameter rhs: Right hand component
 - Returns: A boolean value, true if both Components are equal
 */
public func ==(lhs: Component, rhs: Component) -> Bool {
  return lhs.title == rhs.title &&
    lhs.kind == rhs.kind &&
    lhs.span == rhs.span &&
    (lhs.meta as NSDictionary).isEqual(rhs.meta as NSDictionary) &&
    lhs.items == rhs.items
}
