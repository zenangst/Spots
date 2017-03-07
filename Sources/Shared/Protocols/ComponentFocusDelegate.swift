public protocol ComponentFocusDelegate: class {
  var focusedSpot: CoreComponent? { get set }
  var focusedItemIndex: Int? { get set }
}
