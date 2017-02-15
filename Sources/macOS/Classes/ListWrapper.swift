import Cocoa

class ListWrapper: NSTableRowView, Wrappable {

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
}
