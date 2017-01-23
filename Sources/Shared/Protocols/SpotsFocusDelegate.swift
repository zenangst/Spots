public protocol SpotsFocusDelegate: class {
  var focusedSpot: Spotable? { get set }
  var focusedItemIndex: Int? { get set }
}
