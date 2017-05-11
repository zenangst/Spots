#if os(OSX)
  import Foundation
#else
  import UIKit
#endif

import Tailor

/// The ComponentModel struct is used to configure a Component object
public struct ComponentModel: Mappable, Equatable, DictionaryConvertible {

  /// An enum with all the string keys used in the view model
  public enum Key: String, StringConvertible {
    case index
    case identifier
    case header
    case kind
    case meta
    case span
    case layout
    case interaction
    case items
    case size
    case width
    case height
    case footer

    public var string: String {
      return rawValue.lowercased()
    }
  }

  /// Identifier
  public var identifier: String?
  /// The index of the Item when appearing in a list, should be computed and continuously updated by the data source
  public var index: Int = 0
  /// Determines which component that should be used.
  /// Default kinds are: list, grid and carousel
  public var kind: ComponentKind = .list
  /// The header identifier
  public var header: Item?
  /// User interaction properties
  public var interaction: Interaction
  /// The footer identifier
  public var footer: Item?
  /// Layout properties
  public var layout: Layout?
  /// A collection of view models
  public var items: [Item] = [Item]()
  /// The width and height of the component, usually calculated and updated by the UI component
  public var size: CGSize? = .zero
  /// A key-value dictionary for any additional information
  public var meta = [String: Any]()

  /// A dictionary representation of the component
  public var dictionary: [String : Any] {
    return dictionary()
  }

  /// A method that creates a dictionary representation of the ComponentModel
  ///
  /// - parameter amountOfItems: An optional Int that is used to limit the amount of items that should be transformed into JSON
  ///
  /// - returns: A dictionary representation of the ComponentModel
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

    var JSONComponentModels: [String : Any] = [
      Key.index.string: index,
      Key.kind.string: kind.string,
      Key.size.string: [
        Key.width.string: width,
        Key.height.string: height
      ],
      Key.items.string: JSONItems
      ]

    if let layout = layout {
      JSONComponentModels[Key.layout] = layout.dictionary
    }

    JSONComponentModels[Key.interaction] = interaction.dictionary
    JSONComponentModels[Key.identifier.string] = identifier

    JSONComponentModels[Key.header.string] = header?.dictionary
    JSONComponentModels[Key.footer.string] = footer?.dictionary

    if !meta.isEmpty {
      JSONComponentModels[Key.meta.string] = meta
    }

    return JSONComponentModels
  }

  /// Initializes a component with a JSON dictionary and maps the keys of the dictionary to its corresponding values.
  ///
  /// - parameter map: A JSON key-value dictionary.
  ///
  /// - returns: An initialized component using JSON.
  public init(_ map: [String : Any]) {
    self.identifier = map.string(Key.identifier.rawValue)
    self.kind <- map.enum(Key.kind.rawValue)
    self.header = map.relation(Key.header.rawValue)
    self.footer = map.relation(Key.footer.rawValue)
    self.items <- map.relations(Key.items.rawValue)
    self.meta <- map.property(Key.meta.rawValue)

    if let layoutDictionary: [String : Any] = map.property(Layout.rootKey) {
      self.layout = Layout(layoutDictionary)
    }

    if let interactionDictionary: [String : Any] = map.property(Interaction.rootKey) {
      self.interaction = Interaction(interactionDictionary)
    } else {
      self.interaction = Interaction()
    }

    let width: Double = map.resolve(keyPath: "size.width") ?? 0.0
    let height: Double = map.resolve(keyPath: "size.height") ?? 0.0
    size = CGSize(width: width, height: height)
  }

  /// Initializes a component and configures it with the provided parameters
  ///
  /// - parameter identifier: A optional string.
  /// - parameter header: Determines which header item that should be used for the model.
  /// - parameter kind: The type of ComponentModel that should be used.
  /// - parameter layout: Configures the layout properties for the model.
  /// - parameter interaction: Configures the interaction properties for the model.
  /// - parameter span: Configures the layout span for the model.
  /// - parameter items: A collection of view models
  ///
  /// - returns: An initialized component
  public init(identifier: String? = nil,
              header: Item? = nil,
              footer: Item? = nil,
              kind: ComponentKind = Configuration.defaultComponentKind,
              layout: Layout? = nil,
              interaction: Interaction = .init(),
              items: [Item] = [],
              meta: [String : Any] = [:]) {
    self.identifier = identifier
    self.kind = kind
    self.layout = layout
    self.interaction = interaction
    self.header = header
    self.footer = footer
    self.items = items
    self.meta = meta
    self.layout = layout
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
  /// - parameter component: A ComponentModel used for comparison
  ///
  /// - returns: A ComponentModelDiff value, see ComponentModelDiff for values.
  public func diff(model: ComponentModel) -> ComponentModelDiff {
    // Determine if the UI component is the same, used when Controller needs to replace the entire UI component
    if kind != model.kind {
      return .kind
    }
    // Determine if the unqiue identifier for the component changed
    if identifier != model.identifier {
      return .identifier
    }
    // Determine if the component layout changed, this can be used to trigger layout related processes
    if layout != model.layout {
      return .layout
    }

    // Determine if the header for the component has changed
    if !optionalCompare(lhs: header, rhs: model.header) {
      return .header
    }

    // Determine if the header for the component has changed
    if !optionalCompare(lhs: footer, rhs: model.footer) {
      return .footer
    }

    // Check if meta data for the component changed, this can be up to the developer to decide what course of action to take.
    if !(meta as NSDictionary).isEqual(to: model.meta) {
      return .meta
    }

    // Check if the items have changed
    if !(items === model.items) {
      return .items
    }

    // Check children
    let lhsChildren = items.flatMap { $0.children }
    let rhsChildren = model.items.flatMap { $0.children }

    if !(lhsChildren as NSArray).isEqual(to: rhsChildren) {
      return .items
    }

    return .none
  }

  /// Add child component for composition.
  ///
  /// - Parameter child: The child component model that will be added.
  mutating public func add(child: ComponentModel) {
    var item = Item(kind: CompositeComponent.identifier)
    item.children = [child.dictionary]
    items.append(item)
  }

  /// Add child components for composition.
  ///
  /// - Parameter children: A collection of component models that will be added.
  mutating public func add(children: [ComponentModel]) {
    for child in children {
      add(child: child)
    }
  }

  /// Add layout to component.
  ///
  /// - Parameter layout: A layout model.
  mutating public func add(layout: Layout) {
    self.layout = layout
  }

  /// Perform mutations on the existing layout
  ///
  /// - Parameter layout: The layout that will be used on the component model.
  /// - Returns: The component that was mutated.
  mutating public func configure(with layout: Layout) -> ComponentModel {
    var copy = self
    copy.layout = layout
    return copy
  }
}
