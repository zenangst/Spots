public protocol ComponentFocusDelegate: class {
  var focusedSpot: Component? { get set }
  var focusedItemIndex: Int? { get set }
}
