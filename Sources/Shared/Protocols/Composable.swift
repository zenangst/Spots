/// A protocol used for composition inside components.
public protocol Composable: class {

  /// A required content view, needed because of Composable extensions
  var contentView: View { get }

  /// Configure a Composable with an item and a collection of components.
  ///
  /// - parameter item:  The Item struct that is Composable
  /// - parameter components: A collection of components. that should be used to configure the child
  func configure(_ item: inout Item, compositeComponents: [CompositeComponent]?)
}
