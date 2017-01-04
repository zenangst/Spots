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
    return lhs.itemIndex == rhs.itemIndex
  }

  weak var parentSpot: Spotable?
  var spot: Spotable
  var itemIndex: Int

  init(spot: Spotable, parentSpot: Spotable? = nil, itemIndex: Int) {
    self.itemIndex = itemIndex
    self.parentSpot = parentSpot
    self.spot = spot
    #if !os(OSX)
    self.spot.focusDelegate = parentSpot?.focusDelegate
    #endif
  }
}
