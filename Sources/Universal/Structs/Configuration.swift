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
  public enum ResizeBehavior {
    // Sets the frame of the component to zero if it is not on screen.
    case `default`
    // Sets the components frame to the size of the content size of the component.
    case contentSize
  }

  public static let shared: Configuration = Configuration()

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
  #if os(iOS)
    // Sets the kind of resizing constraints that `SpotsScrollView` should use.
    public var componentResizeBehavior: ResizeBehavior = .default
  #endif
  public var defaultComponentKind: ComponentKind = .grid
  public var defaultViewSize: CGSize = .init(width: 0, height: PlatformDefaults.defaultHeight)
  public var views: Registry = .init()
  public var removeEmptyComponents: Bool = false
  var presenters: [String: AnyPresenter] = .init()
  var coders: [String: AnyItemModelCoder] = .init()
  var modelCoder: AnyItemModelCoder?
  open var configureComponent: ((Component) -> Void)?

  public init() {}

  /// Register a nib file with identifier on the component.
  ///
  /// - parameter nib:        A Nib file that should be used for identifier
  /// - parameter identifier: A StringConvertible identifier for the registered nib.
  public func register(nib: Nib, identifier: StringConvertible) {
    self.views.storage[identifier.string] = Registry.Item.nib(nib)
  }

  /// Register a presenter with an identifier
  ///
  /// - parameter presenter: Model -> View presenter
  public func register<V, M>(presenter: Presenter<V, M>) {
    let identifier = presenter.identifier
    self.views.storage[identifier.string] = Registry.Item.classType(V.self)
    self.presenters[identifier.string] = presenter
    self.coders[identifier.string] = ItemModelCoder<M>()
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

  public func registerComponentModel<T: ComponentSubModel>(_ model: T.Type) {
    modelCoder = ItemModelCoder<T>()
  }
}
