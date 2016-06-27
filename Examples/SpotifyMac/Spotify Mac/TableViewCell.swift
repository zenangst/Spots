import Cocoa
import Spots
import Brick
import Imaginary

public class TableViewCell: NSTableRowView, SpotConfigurable {

  public var size = CGSize(width: 0, height: 88)

  public override var selected: Bool {
    didSet {
      if selected {
        layer?.backgroundColor = NSColor.blackColor().colorWithAlphaComponent(0.85).CGColor
      } else {
        layer?.backgroundColor = NSColor(red:0.157, green:0.157, blue:0.157, alpha: 1).CGColor
      }
    }
  }

  lazy var imageView = NSImageView()

  public lazy var titleLabel = NSTextField().then {
    $0.editable = false
    $0.selectable = false
    $0.bezeled = false
    $0.textColor = NSColor.whiteColor()
    $0.drawsBackground = false
  }

  public lazy var subtitleLabel = NSTextField().then {
    $0.editable = false
    $0.selectable = false
    $0.bezeled = false
    $0.textColor = NSColor.lightGrayColor()
    $0.drawsBackground = false
  }

  lazy var lineView = NSView().then {
    $0.frame.size.height = 1
    $0.wantsLayer = true
    $0.layer = CALayer()
    $0.layer?.backgroundColor = NSColor.grayColor().colorWithAlphaComponent(0.1).CGColor
    $0.autoresizingMask = .ViewWidthSizable
  }

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    wantsLayer = true
    layer = CALayer()
    layer?.backgroundColor = NSColor(red:0.157, green:0.157, blue:0.157, alpha: 1).CGColor

    addSubview(imageView)
    addSubview(titleLabel)
    addSubview(subtitleLabel)
    addSubview(lineView)
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func configure(inout item: ViewModel) {
    titleLabel.stringValue = item.title
    subtitleLabel.stringValue = item.subtitle
    titleLabel.frame.origin.x = 10
    subtitleLabel.frame.origin.x = 10

    titleLabel.frame.origin.y = item.size.height / 2 - titleLabel.frame.size.height / 2

    if item.subtitle.isPresent {
      titleLabel.frame.origin.y = 15
      titleLabel.font = NSFont.boldSystemFontOfSize(14)
      titleLabel.sizeToFit()
      subtitleLabel.sizeToFit()
      titleLabel.frame.origin.y = item.size.height / 2 - titleLabel.frame.size.height / 2 - subtitleLabel.frame.size.height / 2
      subtitleLabel.frame.origin.y = titleLabel.frame.origin.y + subtitleLabel.frame.size.height
    } else {
      titleLabel.font = NSFont.systemFontOfSize(14)
      titleLabel.sizeToFit()
      subtitleLabel.sizeToFit()
      titleLabel.frame.origin.y = item.size.height / 2 - titleLabel.frame.size.height / 2
    }

    if item.image.isPresent {
      titleLabel.frame.origin.x = 50
      if item.image.hasPrefix("http") {
        imageView.frame.size.width = 40
        imageView.frame.size.height = 40
        imageView.frame.origin.x = 5
        titleLabel.frame.origin.x = imageView.frame.maxX + 5
        subtitleLabel.frame.origin.x = imageView.frame.maxX + 5
        imageView.frame.origin.y = item.size.height / 2 - imageView.frame.size.height / 2 + 1
        imageView.setImage(NSURL(string: item.image))
      }
    }

    lineView.frame.origin.y = item.size.height + 1
  }
}
