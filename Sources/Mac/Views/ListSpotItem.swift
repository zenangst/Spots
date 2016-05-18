import Cocoa
import Brick

public class ListSpotItem: NSTableRowView, SpotConfigurable {

  static public var flipped: Bool {
    get {
      return true
    }
  }

  public override var selected: Bool {
    didSet {
      if selected {
        layer?.backgroundColor = NSColor.blackColor().colorWithAlphaComponent(0.85).CGColor
      } else {
        layer?.backgroundColor = NSColor.blackColor().CGColor
      }
    }
  }

  public var size = CGSize(width: 0, height: 88)

  lazy var titleLabel = NSTextField().then {
    $0.editable = false
    $0.selectable = false
    $0.bezeled = false
    $0.textColor = NSColor.whiteColor()
    $0.drawsBackground = false
  }

  lazy var subtitleLabel = NSTextField().then {
    $0.editable = false
    $0.selectable = false
    $0.bezeled = false
    $0.textColor = NSColor.whiteColor()
    $0.drawsBackground = false
  }

  lazy var lineView = NSView().then {
    $0.frame.size.height = 1
    $0.wantsLayer = true
    $0.layer = CALayer()
    $0.layer?.backgroundColor = NSColor.grayColor().colorWithAlphaComponent(0.4).CGColor
    $0.autoresizingMask = .ViewWidthSizable
  }

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    wantsLayer = true
    layer = CALayer()
    layer?.backgroundColor = NSColor.blackColor().CGColor

    addSubview(titleLabel)
    addSubview(subtitleLabel)
    addSubview(lineView)
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func configure(inout item: ViewModel) {
    titleLabel.stringValue = item.title
    titleLabel.frame.origin.x = 8

    titleLabel.sizeToFit()
    if item.subtitle.isPresent {
      titleLabel.frame.origin.y = 8
      titleLabel.font = NSFont.boldSystemFontOfSize(14)
    } else {
      titleLabel.frame.origin.y = item.size.height / 2 - titleLabel.frame.size.height / 2
    }

    subtitleLabel.frame.origin.x = 8
    subtitleLabel.stringValue = item.subtitle
    subtitleLabel.sizeToFit()
    subtitleLabel.frame.origin.y = titleLabel.frame.origin.y + subtitleLabel.frame.height
    
    lineView.frame.origin.y = item.size.height + 1
  }
}