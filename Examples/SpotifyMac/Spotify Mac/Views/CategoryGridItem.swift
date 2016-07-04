import Spots
import Brick
import Sugar

public class CategoryGridItem: NSCollectionViewItem, SpotConfigurable {

  var item: ViewModel?

  public var size = CGSize(width: 0, height: 88)
  public var customView = FlippedView()

  static public var flipped: Bool {
    get {
      return true
    }
  }

  lazy var customImageView = NSImageView()

  public lazy var titleLabel = NSTextField().then {
    $0.editable = false
    $0.selectable = false
    $0.bezeled = false
    $0.textColor = NSColor.whiteColor()
    $0.drawsBackground = false
    $0.font = NSFont.boldSystemFontOfSize(14)
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

    if let imageView = imageView where
      item.image.isPresent && item.image.hasPrefix("http") {
      customImageView.frame.size.width = item.size.width
      customImageView.frame.size.height = item.size.height
      customImageView.frame.origin.y = customView.frame.height - imageView.frame.height
      customImageView.imageAlignment = .AlignCenter
      customImageView.setImage(NSURL(string: item.image))

      titleLabel.frame.origin.x = imageView.frame.width / 2 - titleLabel.frame.width / 2
      titleLabel.frame.origin.y = imageView.frame.height / 5
    }

    self.item = item
  }
}
