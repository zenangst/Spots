import Cocoa

class ListWrapper: NSTableRowView, Wrappable, Cell {

  public var contentView: View {
    return self
  }

  weak var wrappedView: View?

  func configureWrappedView() {
    wrappedView?.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
  }

  override func layoutSubtreeIfNeeded() {
    super.layoutSubtreeIfNeeded()

    self.wrappedView?.frame = bounds
  }

  override func prepareForReuse() {
    wrappedView?.removeFromSuperview()
  }

  override var isSelected: Bool {
    didSet {
      (wrappedView as? ViewStateDelegate)?.viewStateDidChange(viewState)
    }
  }

  var isHighlighted: Bool = false {
    didSet {
      (wrappedView as? ViewStateDelegate)?.viewStateDidChange(viewState)
    }
  }
}
