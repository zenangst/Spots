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

public struct Configuration {

  /// Default setting for stretching the last `Component` to occupy the full height of `SpotsScrollView`.
  /// See `SpotsScrollView.stretchLastComponent` for more details.
  public static var stretchLastComponent: Bool = false

  public static var defaultComponentKind: ComponentKind = .grid
  public static var defaultViewSize: CGSize = .init(width: 0, height: PlatformDefaults.defaultHeight)
  public static var views: Registry = .init()

  /// Register a nib file with identifier on the component.
  ///
  /// - parameter nib:        A Nib file that should be used for identifier
  /// - parameter identifier: A StringConvertible identifier for the registered nib.
  public static func register(nib: Nib, identifier: StringConvertible) {
    self.views.storage[identifier.string] = Registry.Item.nib(nib)
  }

  /// Register a view with an identifier
  ///
  /// - parameter view:       The view type that should be registered with an identifier.
  /// - parameter identifier: A StringConvertible identifier for the registered view type.
  public static func register(view: View.Type, identifier: StringConvertible) {
    self.views.storage[identifier.string] = Registry.Item.classType(view)
  }

  /// Register default view for the component.
  ///
  /// - parameter view: The view type that should be used as the default view
  public static func registerDefault(view: View.Type) {
    views.defaultItem = Registry.Item.classType(view)
  }
}
