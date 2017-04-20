public struct CompositeComponent: Equatable {

  static let identifier: String = "composite"

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

  var component: Component
  var itemIndex: Int

  init(component: Component, itemIndex: Int) {
    self.itemIndex = itemIndex
    self.component = component
  }
}
