import Cocoa

class ListWrapper: NSTableRowView {

  weak var view: View?

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(with view: View) {
    if let previousView = self.view {
      previousView.removeFromSuperview()
    }

    view.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]

    addSubview(view)
    self.view = view
  }

  override func layoutSubtreeIfNeeded() {
    super.layoutSubtreeIfNeeded()

    self.view?.frame = bounds
  }

  override func prepareForReuse() {
    view?.removeFromSuperview()
  }
}
