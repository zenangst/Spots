import Spots
import Brick
import Sugar

open class FeaturedCell: NSCollectionViewItem, SpotConfigurable {

  var item: Item?

  open var preferredViewSize: CGSize = CGSize(width: 500, height: 365)
  open var customView = FlippedView().then {
    $0.wantsLayer = true
    $0.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
  }

  static open var flipped: Bool {
    get {
      return true
    }
  }

  lazy var customImageView = NSImageView().then {
    $0.autoresizingMask = .viewWidthSizable
  }

  override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nil, bundle: nil)

    customView.addSubview(customImageView)

    setupConstraints()
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupConstraints() {
    customView.translatesAutoresizingMaskIntoConstraints = false
    customImageView.translatesAutoresizingMaskIntoConstraints = false

    customImageView.topAnchor.constraint(equalTo: customImageView.superview!.topAnchor).isActive = true
    customImageView.bottomAnchor.constraint(equalTo: customImageView.superview!.bottomAnchor).isActive = true
    customImageView.leftAnchor.constraint(equalTo: customImageView.superview!.leftAnchor).isActive = true
    customImageView.rightAnchor.constraint(equalTo: customImageView.superview!.rightAnchor).isActive = true
  }

  open override func loadView() {
    view = customView
  }

  open func configure(_ item: inout Item) {
    customView.layer?.anchorPoint = CGPoint(x: 0.0, y: 0.0)
    self.item = item

    if item.image.isPresent && item.image.hasPrefix("http") {
      customImageView.imageAlignment = .alignTop
      customImageView.setImage(url: NSURL(string: item.image) as URL?) { [customImageView = customImageView] _ in
        customImageView.contentMode = .scaleToAspectFit
      }
    }
  }
}
