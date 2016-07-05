import Cocoa
import Spots
import Brick
import Imaginary
import Hue

public class GridListItem: NSCollectionViewItem, SpotConfigurable {

  public var item: ViewModel?
  public var size = CGSize(width: 0, height: 88)

  static public var flipped: Bool {
    get { return true }
  }

  lazy var customView = TableRow(frame: CGRect(x: 0, y: 0, width: 0, height: 0))

  public override func loadView() {
    view = NSView()
    view.addSubview(customView)
    view.autoresizesSubviews = true
    customView.autoresizingMask = [.ViewWidthSizable, .ViewHeightSizable]
  }

  public func configure(inout item: ViewModel) {
    customView.configure(&item)
    customView.acceptsTouchEvents = false
    item.size.height = customView.size.height
  }
}
