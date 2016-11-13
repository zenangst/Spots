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
    let top: CGFloat = component.meta("inset-top", 0.0)
    let left: CGFloat = component.meta("inset-left", 0.0)
    let bottom: CGFloat = component.meta("inset-bottom", 0.0)
    let right: CGFloat = component.meta("inset-right", 0.0)

    render().contentInsets = EdgeInsets(top: top, left: left, bottom: bottom, right: right)
  }

  public func deselect() {
    tableView.deselectAll(nil)
  }

  @discardableResult public func selectFirst() -> Self {
    guard let item = item(at: 0), !component.items.isEmpty else { return self }
    tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
    delegate?.didSelect(item: item, in: self)

    return self
  }

  public func refreshHeight(_ completion: (() -> Void)? = nil) {
    layout(CGSize(width: tableView.frame.width, height: computedHeight ))
    completion?()
  }
}
