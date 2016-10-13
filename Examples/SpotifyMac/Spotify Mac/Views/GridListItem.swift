import Cocoa
import Spots
import Brick
import Imaginary
import Hue

open class GridListItem: NSCollectionViewItem, SpotConfigurable {

  open var item: Item?
  open var preferredViewSize: CGSize = CGSize(width: 0, height: 88)

  static open var flipped: Bool {
    get { return true }
  }

  lazy var customView = TableRow(frame: CGRect(x: 0, y: 0, width: 0, height: 0))

  open override func loadView() {
    view = NSView()
    view.addSubview(customView)
    view.autoresizesSubviews = true
    customView.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
  }

  open func configure(_ item: inout Item) {
    customView.configure(&item)
    customView.acceptsTouchEvents = false
    item.size.height = customView.frame.size.height
  }
}
