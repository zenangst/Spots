import Cocoa

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

  func configureLayout(_ model: ComponentModel) {
    let top: CGFloat = model.meta("inset-top", 0.0)
    let left: CGFloat = model.meta("inset-left", 0.0)
    let bottom: CGFloat = model.meta("inset-bottom", 0.0)
    let right: CGFloat = model.meta("inset-right", 0.0)

    view.contentInsets = EdgeInsets(top: top, left: left, bottom: bottom, right: right)
  }

  public func deselect() {
    tableView.deselectAll(nil)
  }

  @discardableResult public func selectFirst() -> Self {
    guard let item = item(at: 0), !model.items.isEmpty else { return self }
    tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
    delegate?.component(self, itemSelected: item)

    return self
  }

  public func refreshHeight(_ completion: (() -> Void)? = nil) {
    layout(CGSize(width: tableView.frame.width, height: computedHeight ))
    completion?()
  }
}
