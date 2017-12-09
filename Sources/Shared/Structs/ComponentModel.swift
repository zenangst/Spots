#if os(OSX)
  import Foundation
#else
  import UIKit
#endif

/// The ComponentModel struct is used to configure a Component object
public struct ComponentModel: Codable, Equatable {
  /// An enum with all the string keys used in the view model
  public enum Key: String, CodingKey {
    case identifier
    case index
    case kind
    case header
    case interaction
    case footer
    case model
    case layout
    case items
    case size
    case meta
    case amountOfItemsToCache
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
  public var layout: Layout
  /// A collection of view models
  public var items: [Item] = [Item]()
  /// The width and height of the component, usually calculated and updated by the UI component
  public var size: CGSize = .zero
  /// A key-value dictionary for any additional information
  public var meta = [String: Any]()
  /// An optional Int that is used to limit the amount of items that should be transformed into JSON
  public var amountOfItemsToCache: Int?

  /// An optional Codable model
  var model: ComponentModelCodable?

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
              kind: ComponentKind = Configuration.shared.defaultComponentKind,
              layout: Layout = Layout(),
              interaction: Interaction = .init(),
              items: [Item] = [],
              meta: [String : Any] = [:]) {
    self.identifier = identifier
    self.kind = kind
    self.layout = layout
    self.interaction = interaction
    self.header = header
    self.footer = footer
    self.items = items.refreshIndexes()
    self.meta = meta
  }

  // MARK: - Codable

  /// Initialize with a decoder.
  ///
  /// - Parameter decoder: A decoder that can decode values into in-memory representations.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Key.self)
    self.identifier = try container.decodeIfPresent(String.self, forKey: .identifier)
    self.index = try container.decodeIfPresent(Int.self, forKey: .index) ?? 0
    self.kind = try container.decodeIfPresent(ComponentKind.self, forKey: .kind) ?? .list
    self.header = try container.decodeIfPresent(Item.self, forKey: .header)
    self.interaction = try container.decodeIfPresent(Interaction.self,
                                                     forKey: .interaction) ?? Interaction()
    self.footer = try container.decodeIfPresent(Item.self, forKey: .footer)
    self.layout = try container.decodeIfPresent(Layout.self, forKey: .layout) ?? Layout()
    self.model = try container.decodeIfPresentWithModelCoder(forKey: .model)
    self.items = try container.decodeIfPresent([Item].self, forKey: .items)?.refreshIndexes() ?? []
    self.size = try container.decodeIfPresent(Size.self, forKey: .size)?.cgSize ?? .zero
    self.meta = container.decodeJsonDictionaryIfPresent(forKey: .meta) ?? [:]
    self.amountOfItemsToCache = try container.decodeIfPresent(Int.self, forKey: .amountOfItemsToCache)
  }

  /// Encode the struct into data.
  ///
  /// - Parameter encoder: An encoder that can encode the struct into data.

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: Key.self)
    try container.encodeIfPresent(identifier, forKey: .identifier)
    try container.encode(index, forKey: .index)
    try container.encode(kind, forKey: .kind)
    try container.encodeIfPresent(header, forKey: .header)
    try container.encode(interaction, forKey: .interaction)
    try container.encodeIfPresent(footer, forKey: .footer)
    try container.encode(layout, forKey: .layout)

    let itemsToCache: [Item]

    if let amountOfItems = amountOfItemsToCache {
      itemsToCache = Array(items[0..<min(amountOfItems, items.count)])
    } else {
      itemsToCache = items
    }

    try container.encodeIfPresent(itemsToCache, forKey: .items)
    try container.encodeIfPresent(Size(cgSize: size), forKey: .size)
    container.encode(jsonDictionary: meta, forKey: .meta)
    try container.encodeIfPresent(amountOfItemsToCache, forKey: .amountOfItemsToCache)
    try container.encodeIfPresentWithModel(model, forKey: .model)
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

    var modelsAreEqual: Bool = true
    if let lhsModel = self.model {
      if let rhsModel = model.model {
        modelsAreEqual = lhsModel.equal(to: rhsModel)
      } else {
        modelsAreEqual = false
      }
    }

    if !modelsAreEqual {
      return .model
    }

    // Check if the items have changed
    if !(items === model.items) {
      return .items
    }

    return .none
  }

  /// A generic convenience method for resolving a model
  ///
  /// - Returns: A generic model based on `type`
  public func resolveModel<T: ComponentSubModel>() -> T? {
    return model as? T
  }

  /// A generic convenience method for updating a model
  ///
  /// - Parameter model: The model that should be updated.
  public mutating func update<T: ComponentSubModel>(model: T) {
    self.model = model
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
