import Cocoa
import Brick

extension Listable {

  public var responder: NSResponder {
    return tableView
  }

  public var nextResponder: NSResponder? {
    get {
      return tableView.nextResponder
    }
    set {
      tableView.nextResponder = newValue
    }
  }

  func configureLayout(_ component: Component) {
    let top: CGFloat = component.meta("insetTop", 0.0)
    let left: CGFloat = component.meta("insetLeft", 0.0)
    let bottom: CGFloat = component.meta("insetBottom", 0.0)
    let right: CGFloat = component.meta("insetRight", 0.0)

    render().contentInsets = EdgeInsets(top: top, left: left, bottom: bottom, right: right)
  }

  public func deselect() {
    tableView.deselectAll(nil)
  }

  @discardableResult public func selectFirst() -> Self {
    guard let viewModel = item(at: 0), !component.items.isEmpty else { return self }
    tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
    spotsDelegate?.spotDidSelectItem(self, item: viewModel)

    return self
  }
}
