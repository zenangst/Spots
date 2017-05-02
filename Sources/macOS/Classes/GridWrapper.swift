import Cocoa

class GridWrapper: NSCollectionViewItem, Wrappable, Cell {

  public var bounds: CGRect {
    return coreView.bounds
  }

  weak var wrappedView: View? {
    didSet { wrappableViewChanged() }
  }

  public var contentView: View {
    return coreView
  }

  var isFlipped: Bool = true

  open var coreView: FlippedView = FlippedView()

  open override func loadView() {
    view = coreView
  }

  override func viewWillLayout() {
    super.viewWillLayout()

    self.wrappedView?.frame = coreView.bounds
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
