import Cocoa
import Spots
import Brick

public class GridSpotItem: NSCollectionViewItem, SpotConfigurable {

  public var size = CGSize(width: 0, height: 88)
  public var customView = NSView()

  public override func loadView() {
    view = customView
  }

  override public func viewDidLoad() {
    super.viewDidLoad()
    view.wantsLayer = true
    view.layer?.backgroundColor = NSColor.blackColor().CGColor
  }

  public func configure(inout item: ViewModel) {
    title = item.title
    NSLog("item : \(item.title)")
  }
}