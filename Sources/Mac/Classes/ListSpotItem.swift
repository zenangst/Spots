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

  public var preferredViewSize: CGSize(width: 0, height: 88)

  lazy var titleLabel: NSTextField = {
    let titleLabel = NSTextField()
    titleLabel.editable = false
    titleLabel.selectable = false
    titleLabel.bezeled = false
    titleLabel.textColor = NSColor.whiteColor()
    titleLabel.drawsBackground = false

    return titleLabel
  }()

  lazy var subtitleLabel: NSTextField = {
    let subtitleLabel = NSTextField()
    subtitleLabel.editable = false
    subtitleLabel.selectable = false
    subtitleLabel.bezeled = false
    subtitleLabel.textColor = NSColor.lightGrayColor()
    subtitleLabel.drawsBackground = false

    return subtitleLabel
  }()

  lazy var lineView: NSView = {
    let lineView = NSView()
    lineView.frame.size.height = 1
    lineView.wantsLayer = true
    lineView.layer = CALayer()
    lineView.layer?.backgroundColor = NSColor.grayColor().colorWithAlphaComponent(0.4).CGColor
    lineView.autoresizingMask = .ViewWidthSizable

    return lineView
  }()

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

  public func configure(inout item: Item) {
    titleLabel.stringValue = item.title
    titleLabel.frame.origin.x = 8

    titleLabel.sizeToFit()
    if !item.subtitle.isEmpty {
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
