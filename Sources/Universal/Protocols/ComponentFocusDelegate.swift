public protocol ComponentFocusDelegate: class {
  var focusedComponent: Component? { get set }
  var focusedItemIndex: Int? { get set }
  var focusedView: View? { get set }
}
