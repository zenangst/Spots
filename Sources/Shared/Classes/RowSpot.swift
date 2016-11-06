/// A RowSpot, a collection view based Spotable object that lays out its items in a vertical order based of the item sizes
open class RowSpot: GridSpot {

  /// A required initializer to instantiate a RowSpot with a component.
  ///
  /// - parameter component: A component.
  ///
  /// - returns: An initialized row spot with component.
  required init(component: Component) {
    var component = component
    component.span = 1

    if component.kind.isEmpty {
      component.kind = Component.Kind.Row.string
    }

    super.init(component: component)
  }
}
