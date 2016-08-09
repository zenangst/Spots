import Cocoa
import Spots
import Brick
import Imaginary

public class TableRow: NSTableRowView, SpotConfigurable {

  public var item: ViewModel?
  public var size = CGSize(width: 0, height: 50)

  public var tintColor: NSColor? {
    get {
      if let hexColor = item?.meta("tintColor", type: String.self) {
        return NSColor.hex(hexColor)
      }

      return nil
    }
  }

  public override var selected: Bool {
    didSet {
      if selected {
        titleLabel.textColor = tintColor
        subtitleLabel.textColor = tintColor
        if tintColor != nil {
          imageView.tintColor = tintColor
        }
        layer?.backgroundColor = NSColor(red:0.1, green:0.1, blue:0.1, alpha: 0.985).CGColor
      } else {
        titleLabel.textColor = NSColor.lightGrayColor()
        subtitleLabel.textColor = NSColor.darkGrayColor()
        if tintColor != nil { imageView.tintColor = NSColor.grayColor() }
        layer?.backgroundColor = NSColor.clearColor().CGColor
        self.shadow = nil
      }
    }
  }

  lazy var imageView = NSImageView()

  public lazy var titleLabel = NSTextField().then {
    $0.editable = false
    $0.bezeled = false
    $0.textColor = NSColor.whiteColor()
    $0.drawsBackground = false
  }

  public lazy var subtitleLabel = NSTextField().then {
    $0.editable = false
    $0.bezeled = false
    $0.drawsBackground = false
    $0.cell?.wraps = true
    $0.cell?.lineBreakMode = .ByWordWrapping
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

    selectionHighlightStyle = .None
    backgroundColor = NSColor.clearColor()
    wantsLayer = true
    layer = CALayer()
    addSubview(titleLabel)
    addSubview(subtitleLabel)
    addSubview(lineView)
    addSubview(imageView)

    setupConstraints()
  }

  override public func hitTest(aPoint: NSPoint) -> NSView? {
    return nil
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func setupConstraints() {
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

    titleLabel.leftAnchor.constraintEqualToAnchor(imageView.rightAnchor, constant: 10).active = true
    titleLabel.rightAnchor.constraintEqualToAnchor(titleLabel.superview!.rightAnchor, constant: -10).active = true
    titleLabel.centerYAnchor.constraintEqualToAnchor(titleLabel.superview!.centerYAnchor).active = true
  }

  public func configure(inout item: ViewModel) {

    if item.meta("separator", type: Bool.self) == false {
      lineView.frame.size.height = 0.0
    } else {
      lineView.frame.size.height = 1.0
    }

    titleLabel.stringValue = item.title
    subtitleLabel.stringValue = item.subtitle

    if item.subtitle.isPresent {
      titleLabel.font = NSFont.boldSystemFontOfSize(12)
    } else {
      titleLabel.font = NSFont.systemFontOfSize(12)
    }

    self.item = item

    if item.image.isPresent {
      titleLabel.frame.origin.x = 50

      if item.image.hasPrefix("http") {
        imageView.frame.size.width = 40
        imageView.frame.size.height = 40
        imageView.frame.origin.x = 5
        imageView.frame.origin.y = item.size.height / 2 - imageView.frame.size.height / 2

        imageView.setImage(NSURL(string: item.image))
      } else {
        imageView.image = NSImage(named: item.image)
        imageView.frame.size.width = 18
        imageView.frame.size.height = 18
        imageView.frame.origin.x = 10
        imageView.frame.origin.y = item.size.height / 2 - imageView.frame.size.height / 2 + 1
        if tintColor != nil {
          imageView.tintColor = NSColor.grayColor()
        }
      }
    }

    lineView.frame.origin.y = item.size.height
  }
}
