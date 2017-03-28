import Cocoa

class ListWrapper: NSTableRowView, Wrappable, Cell {

  public var contentView: View { return self }
  weak var wrappedView: View?

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
}
