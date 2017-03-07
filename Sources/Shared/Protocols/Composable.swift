/// A protocol used for composition inside CoreComponent objects
public protocol Composable: class {

  /// A required content view, needed because of Composable extensions
  var contentView: View { get }

  /// Configure a Composable with an item and a collection of CoreComponent objects
  ///
  /// - parameter item:  The Item struct that is Composable
  /// - parameter components: A collection of CoreComponent objects that should be used to configure the child
  func configure(_ item: inout Item, compositeComponents: [CompositeComponent]?)
}
