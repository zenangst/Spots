import Spots
import Brick
import Sugar

open class CategoryGridItem: NSCollectionViewItem, SpotConfigurable {

  var item: Item?

  open var preferredViewSize: CGSize = CGSize(width: 0, height: 88)
  open var customView = FlippedView()

  static open var flipped: Bool {
    get {
      return true
    }
  }

  lazy var customImageView = NSImageView()

  open lazy var titleLabel = NSTextField().then {
    $0.isEditable = false
    $0.isSelectable = false
    $0.isBezeled = false
    $0.textColor = NSColor.white
    $0.drawsBackground = false
    $0.font = NSFont.boldSystemFont(ofSize: 14)
  }

  open lazy var subtitleLabel = NSTextField().then {
    $0.isEditable = false
    $0.isSelectable = false
    $0.isBezeled = false
    $0.textColor = NSColor.lightGray
    $0.drawsBackground = false
  }

  override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nil, bundle: nil)

    imageView = customImageView

    view.addSubview(customImageView)
    view.addSubview(titleLabel)
    view.addSubview(subtitleLabel)
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open override func loadView() {
    view = customView
  }

  open func configure(_ item: inout Item) {
    titleLabel.stringValue = item.title
    titleLabel.frame.origin.x = 8
    titleLabel.sizeToFit()
    if item.subtitle.isPresent {
      titleLabel.frame.origin.y = 8
      titleLabel.font = NSFont.boldSystemFont(ofSize: 14)
      titleLabel.sizeToFit()
    } else {
      titleLabel.frame.origin.y = item.size.height / 2 - titleLabel.frame.size.height / 2
    }

    subtitleLabel.frame.origin.x = 8
    subtitleLabel.stringValue = item.subtitle
    subtitleLabel.sizeToFit()
    subtitleLabel.frame.origin.y = titleLabel.frame.origin.y + subtitleLabel.frame.height

    if let imageView = imageView ,
      item.image.isPresent && item.image.hasPrefix("http") {
      customImageView.frame.size.width = item.size.width
      customImageView.frame.size.height = item.size.height
      customImageView.frame.origin.y = customView.frame.height - imageView.frame.height
      customImageView.imageAlignment = .alignCenter
      customImageView.setImage(url: NSURL(string: item.image) as URL?)

      titleLabel.frame.origin.x = imageView.frame.width / 2 - titleLabel.frame.width / 2
      titleLabel.frame.origin.y = imageView.frame.height / 5
    }

    self.item = item
  }
}
