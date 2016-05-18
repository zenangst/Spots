import Cocoa
import Spots
import Brick

public class TableViewCell: NSTableRowView, SpotConfigurable {

  lazy var titleLabel = NSTextField().then {
    $0.editable = false
    $0.selectable = false
    $0.bezeled = false
    $0.textColor = NSColor.whiteColor()
    $0.drawsBackground = false
  }

  public var size = CGSize(width: 0, height: 88)
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    wantsLayer = true
    layer = CALayer()
    layer?.backgroundColor = NSColor.blackColor().CGColor

    addSubview(titleLabel)
  }
  
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func configure(inout item: ViewModel) {
    titleLabel.frame.origin.y = 15
    titleLabel.frame.origin.x = 40
    titleLabel.stringValue = item.title
    titleLabel.sizeToFit()
  }

  public override func layoutSubtreeIfNeeded() {
    super.layoutSubtreeIfNeeded()
  }
}