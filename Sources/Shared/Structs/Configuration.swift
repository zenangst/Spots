public struct Configuration {

  public static var views: Registry = Registry(useCache: false)

  /// Register a nib file with identifier on the CoreComponent object.
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

  /// Register default view for the CoreComponent object
  ///
  /// - parameter view: The view type that should be used as the default view
  public static func registerDefault(view: View.Type) {
    views.defaultItem = Registry.Item.classType(view)
  }
}
