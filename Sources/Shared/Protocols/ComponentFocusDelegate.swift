public protocol ComponentFocusDelegate: class {
  var focusedSpot: Spotable? { get set }
  var focusedItemIndex: Int? { get set }
}
