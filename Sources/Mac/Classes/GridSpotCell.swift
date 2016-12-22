import Cocoa
import Brick

class GridSpotCell: NSCollectionViewItem, SpotConfigurable {

  var preferredViewSize: CGSize = CGSize(width: 0, height: 120)

  open override func loadView() {
    view = NSView()
  }

  func configure(_ item: inout Item) {
    view.wantsLayer = true
    view.layer?.backgroundColor = NSColor.red.cgColor
  }
}
