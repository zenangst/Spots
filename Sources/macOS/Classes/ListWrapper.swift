import Cocoa

class ListWrapper: NSTableRowView, Wrappable, Cell {

  public var contentView: View { return self }

  weak var wrappedView: View? {
    didSet { wrappableViewChanged() }
  }

  override var isSelected: Bool {
    didSet { (wrappedView as? ViewStateDelegate)?.viewStateDidChange(viewState) }
  }

  var isHighlighted: Bool = false {
    didSet { (wrappedView as? ViewStateDelegate)?.viewStateDidChange(viewState) }
  }

  override func setFrameSize(_ newSize: NSSize) {
    super.setFrameSize(newSize)
    self.wrappedView?.frame.size = newSize
  }

  override func prepareForReuse() {
    wrappedView?.removeFromSuperview()
  }

  override func mouseEntered(with event: NSEvent) {
    super.mouseEntered(with: event)

    guard !isSelected else {
      return
    }

    (wrappedView as? ViewStateDelegate)?.viewStateDidChange(.hover)
  }

  override func mouseExited(with event: NSEvent) {
    super.mouseExited(with: event)

    guard !isHighlighted && !isSelected else {
      return
    }

    (wrappedView as? ViewStateDelegate)?.viewStateDidChange(.normal)
  }
}
