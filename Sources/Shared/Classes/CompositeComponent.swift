public struct CompositeComponent: Equatable {
  /// Returns a Boolean value indicating whether two values are equal.
  ///
  /// Equality is the inverse of inequality. For any values `a` and `b`,
  /// `a == b` implies that `a != b` is `false`.
  ///
  /// - Parameters:
  ///   - lhs: A value to compare.
  ///   - rhs: Another value to compare.
  public static func == (lhs: CompositeComponent, rhs: CompositeComponent) -> Bool {
    return lhs.itemIndex == rhs.itemIndex
  }

  weak var parentComponent: Component?
  var component: Component
  var itemIndex: Int

  init(component: Component, parentComponent: Component? = nil, itemIndex: Int) {
    self.itemIndex = itemIndex
    self.parentComponent = parentComponent
    self.component = component
    #if !os(OSX)
    self.component.focusDelegate = parentComponent?.focusDelegate
    #endif
  }
}
