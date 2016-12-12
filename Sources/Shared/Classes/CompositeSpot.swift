public struct CompositeSpot: Equatable {
  /// Returns a Boolean value indicating whether two values are equal.
  ///
  /// Equality is the inverse of inequality. For any values `a` and `b`,
  /// `a == b` implies that `a != b` is `false`.
  ///
  /// - Parameters:
  ///   - lhs: A value to compare.
  ///   - rhs: Another value to compare.
  public static func == (lhs: CompositeSpot, rhs: CompositeSpot) -> Bool {
    return lhs.spot.component == rhs.spot.component &&
      lhs.spotableIndex == rhs.spotableIndex &&
      lhs.itemIndex == rhs.itemIndex
  }

  var parentSpot: Spotable?
  var spot: Spotable
  var spotableIndex: Int
  var itemIndex: Int
}
