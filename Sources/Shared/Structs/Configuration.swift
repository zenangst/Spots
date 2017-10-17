#if os(macOS)
  import Foundation
#else
  import UIKit
#endif

struct PlatformDefaults {
  #if os(macOS)
  static let defaultHeight: CGFloat = 88
  #else
  static let defaultHeight: CGFloat = 44
  #endif
}

public class Configuration {
  public static let shared: Configuration = Configuration()
  public typealias ConfigurationClosure = (_ view: View, _ model: ItemCodable, _ containerSize: CGSize) -> CGSize

  /// When enabled, the last `Component` in the collection will be stretched to occupy the remaining space.
  /// This can be enabled globally by setting `Configuration.stretchLastComponent` to `true`.
  ///
  /// ```
  ///  Enabled    Disabled
  ///  --------   --------
  /// ||¯¯¯¯¯¯|| ||¯¯¯¯¯¯||
  /// ||      || ||      ||
  /// ||______|| ||______||
  /// ||¯¯¯¯¯¯|| ||¯¯¯¯¯¯||
  /// ||      || ||      ||
  /// ||      || ||______||
  /// ||______|| |        |
  ///  --------   --------
  /// ```
  public var stretchLastComponent: Bool = false

  public var defaultComponentKind: ComponentKind = .grid
  public var defaultViewSize: CGSize = .init(width: 0, height: PlatformDefaults.defaultHeight)
  public var views: Registry = .init()
  public var models: [String: ItemCodable.Type] = .init()
  public var presenters: [String: ConfigurationClosure] = .init()

  /// Register a nib file with identifier on the component.
  ///
  /// - parameter nib:        A Nib file that should be used for identifier
  /// - parameter identifier: A StringConvertible identifier for the registered nib.
  public func register(nib: Nib, identifier: StringConvertible) {
    self.views.storage[identifier.string] = Registry.Item.nib(nib)
  }

  /// Register a view with an identifier
  ///
  /// - parameter view:       The view type that should be registered with an identifier.
  /// - parameter identifier: A StringConvertible identifier for the registered view type.
  public func register<T, U: ItemModel>(view: T.Type, identifier: StringConvertible, model: U.Type?, presenter: Presenter<T, U>? = nil) {
    self.views.storage[identifier.string] = Registry.Item.classType(view)

    if let model = model {
      self.models[identifier.string] = model
    }

    if let presenter = presenter {
      self.presenters[identifier.string] = presenter.configure(_:_:_:)
    }
  }

  /// Register a view with an identifier
  ///
  /// - parameter view:       The view type that should be registered with an identifier.
  /// - parameter identifier: A StringConvertible identifier for the registered view type.
  public func register(view: View.Type, identifier: StringConvertible) {
    self.views.storage[identifier.string] = Registry.Item.classType(view)
  }

  /// Register default view for the component.
  ///
  /// - parameter view: The view type that should be used as the default view
  public func registerDefault(view: View.Type) {
    views.defaultItem = Registry.Item.classType(view)
  }
}
