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

  override func mouseDown(with event: NSEvent) {
    super.mouseDown(with: event)

    guard let collectionView = collectionView,
      let delegate = collectionView.delegate as? Delegate,
      let component = delegate.component
      else {
        return
    }

    guard event.clickCount > 1 && component.model.interaction.mouseClick == .double else {
      return
    }

    for index in collectionView.selectionIndexes {
      guard let item = component.item(at: index) else {
        continue
      }
      component.delegate?.component(component, itemSelected: item)
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
