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

  public override var selected: Bool {
    didSet {
      if selected {
        titleLabel.textColor = NSColor.whiteColor()
        subtitleLabel.textColor = NSColor.lightGrayColor()
        if tintColor != nil { 
          customImageView.tintColor = tintColor 
        }
        customView.layer?.backgroundColor = NSColor(red:0.257, green:0.257, blue:0.257, alpha: 1).CGColor
      } else {
        titleLabel.textColor = NSColor.lightGrayColor()
        subtitleLabel.textColor = NSColor.darkGrayColor()
        if tintColor != nil { customImageView.tintColor = NSColor.grayColor() }
        customView.layer?.backgroundColor = NSColor.clearColor().CGColor
      }
    }
  }

  public var tintColor: NSColor? {
    get {
      if let hexColor = item?.meta("tintColor", type: String.self) {
        return NSColor.hex(hexColor)
      }

      return nil
    }
  }

  public var customView = FlippedView()

  lazy var customImageView = NSImageView()

  public lazy var titleLabel = NSTextField().then {
    $0.editable = false
    $0.selectable = false
    $0.bezeled = false
    $0.textColor = NSColor.lightGrayColor()
    $0.drawsBackground = false
  }

  public lazy var subtitleLabel = NSTextField().then {
    $0.editable = false
    $0.selectable = false
    $0.bezeled = false
    $0.textColor = NSColor.darkGrayColor()
    $0.drawsBackground = false
  }

  lazy var lineView = NSView().then {
    $0.frame.size.height = 1
    $0.wantsLayer = true
    $0.layer = CALayer()
    $0.layer?.backgroundColor = NSColor.grayColor().colorWithAlphaComponent(0.3).CGColor
    $0.autoresizingMask = .ViewWidthSizable
  }

  override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nil, bundle: nil)

    view.wantsLayer = true
    view.layer = CALayer()
    view.addSubview(titleLabel)
    view.addSubview(subtitleLabel)
    view.addSubview(lineView)
    view.addSubview(customImageView)
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func loadView() {
    view = customView
  }

  public func configure(inout item: ViewModel) {

    if item.meta("separator", type: Bool.self) == false {
      lineView.frame.size.height = 0.0
    } else {
      lineView.frame.size.height = 1.0
    }

    titleLabel.stringValue = item.title
    subtitleLabel.stringValue = item.subtitle
    titleLabel.frame.origin.x = 10
    subtitleLabel.frame.origin.x = 10

    if item.subtitle.isPresent {
      titleLabel.font = NSFont.boldSystemFontOfSize(14)
      titleLabel.sizeToFit()
      subtitleLabel.sizeToFit()
      subtitleLabel.frame.origin.y = item.size.height / 2 - titleLabel.frame.size.height / 2 - subtitleLabel.frame.size.height / 2
      titleLabel.frame.origin.y = subtitleLabel.frame.origin.y + titleLabel.frame.size.height
    } else {
      titleLabel.font = NSFont.systemFontOfSize(14)
      titleLabel.sizeToFit()
      subtitleLabel.sizeToFit()
      titleLabel.frame.origin.y = item.size.height / 2 - titleLabel.frame.size.height / 2
    }

    self.item = item

    if item.image.isPresent {
      titleLabel.frame.origin.x = 50

      if item.image.hasPrefix("http") {
        customImageView.frame.size.width = 40
        customImageView.frame.size.height = 40
        customImageView.frame.origin.x = 5
        titleLabel.frame.origin.x = customImageView.frame.maxX + 5
        subtitleLabel.frame.origin.x = customImageView.frame.maxX + 5
        customImageView.frame.origin.y = item.size.height / 2 - customImageView.frame.size.height / 2

        customImageView.setImage(NSURL(string: item.image))
      } else {
        customImageView.image = NSImage(named: item.image)
        customImageView.frame.size.width = 18
        customImageView.frame.size.height = 18
        customImageView.frame.origin.x = 10
        titleLabel.frame.origin.x = customImageView.frame.maxX + 5
        subtitleLabel.frame.origin.x = customImageView.frame.maxX + 5
        customImageView.frame.origin.y = item.size.height / 2 - customImageView.frame.size.height / 2 - 1
        if tintColor != nil {
          customImageView.tintColor = NSColor.grayColor()
        }
      }
    }
  }
}
