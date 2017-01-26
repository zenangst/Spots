import Cocoa

class GridWrapper: NSCollectionViewItem {

  static open var flipped: Bool = true

  var isFlipped: Bool = true

  open var coreView: FlippedView = FlippedView()
  weak var customView: View?

  func configure(with view: View) {
    if let previousView = self.customView {
      previousView.removeFromSuperview()
    }

    coreView.addSubview(view)
    self.customView = view
  }

  open override func loadView() {
    view = coreView
  }

  override func viewWillLayout() {
    super.viewWillLayout()

    self.customView?.frame = coreView.bounds
  }

  override func prepareForReuse() {
    customView?.removeFromSuperview()
  }
}
