/// A protocol used for composition inside Spotable objects
public protocol Composable: class {

  /// A required content view, needed because of Composable extensions
  var contentView: View { get }

  /// Configure a Composable with an item and a collection of Spotable objects
  ///
  /// - parameter item:  The Item struct that is Composable
  /// - parameter spots: A collection of Spotable objects that should be used to configure the child
  func configure(_ item: inout Item, compositeComponents: [CompositeComponent]?)
}
