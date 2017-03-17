/// A protocol used for composition inside Component objects
public protocol Composable: class {

  /// A required content view, needed because of Composable extensions
  var contentView: View { get }

  /// Configure a Composable with an item and a collection of Component objects
  ///
  /// - parameter item:  The Item struct that is Composable
  /// - parameter components: A collection of Component objects that should be used to configure the child
  func configure(_ item: inout Item, compositeComponents: [CompositeComponent]?)
}
