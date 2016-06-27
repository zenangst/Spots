import Cocoa

extension Listable {

  func configureLayout(component: Component) {
    let top: CGFloat = component.meta("insetTop", 0.0)
    let left: CGFloat = component.meta("insetLeft", 0.0)
    let bottom: CGFloat = component.meta("insetBottom", 0.0)
    let right: CGFloat = component.meta("insetRight", 0.0)

    render().contentInsets = NSEdgeInsets(top: top, left: left, bottom: bottom, right: right)
  }
}
