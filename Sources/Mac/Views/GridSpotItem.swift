import Cocoa
import Brick

public class FlippedView: NSView {
  static public var flipped: Bool {
    get {
      return true
    }
  }
}

public class GridSpotItem: NSCollectionViewItem, SpotConfigurable {

  static public var flipped: Bool {
    get {
      return true
    }
  }

  public override var selected: Bool {
    didSet {
      if selected {
        view.layer?.backgroundColor = NSColor.blackColor().colorWithAlphaComponent(0.85).CGColor
      } else {
        view.layer?.backgroundColor = NSColor.clearColor().CGColor
      }
    }
  }

  public var size = CGSize(width: 0, height: 88)
  public var customView = FlippedView()

  public lazy var customImageView = NSImageView().then {
    $0.autoresizingMask = .ViewWidthSizable
  }

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

  override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nil, bundle: nil)

    imageView = customImageView

    view.addSubview(customImageView)
    view.addSubview(titleLabel)
    view.addSubview(subtitleLabel)
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func loadView() {
    view = customView
  }

  override public func viewDidLoad() {
    view.wantsLayer = true
    view.layer?.backgroundColor = NSColor.clearColor().CGColor
  }

  public func configure(inout item: ViewModel) {
    titleLabel.stringValue = item.title
    titleLabel.frame.origin.x = 8
    titleLabel.sizeToFit()
    if item.subtitle.isPresent {
      titleLabel.frame.origin.y = 8
      titleLabel.font = NSFont.boldSystemFontOfSize(14)
      titleLabel.sizeToFit()
    } else {
      titleLabel.frame.origin.y = item.size.height / 2 - titleLabel.frame.size.height / 2
    }

    subtitleLabel.frame.origin.x = 8
    subtitleLabel.stringValue = item.subtitle
    subtitleLabel.sizeToFit()
    subtitleLabel.frame.origin.y = titleLabel.frame.origin.y + subtitleLabel.frame.height
  }
}
