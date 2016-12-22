import Spots
import Brick
import Sugar

open class GridCell: NSCollectionViewItem, SpotConfigurable {

  var item: Item?

  open var preferredViewSize: CGSize = CGSize(width: 240, height: 120)
  open var customView = FlippedView()

  static open var flipped: Bool {
    get {
      return true
    }
  }

  lazy var customImageView = NSImageView()

  override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nil, bundle: nil)

    imageView = customImageView

    view.addSubview(customImageView)
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open override func loadView() {
    view = customView
  }

  open func configure(_ item: inout Item) {
    if let imageView = imageView ,
      item.image.isPresent && item.image.hasPrefix("http") {
      customImageView.frame.size.width = item.size.width
      customImageView.frame.size.height = item.size.height
      customImageView.frame.origin.y = customView.frame.height - imageView.frame.height
      customImageView.setImage(url: NSURL(string: item.image) as URL?) { [weak self] image in
        self?.customImageView.contentMode = .scaleToAspectFit
      }
    }
    
    self.item = item
  }
}
