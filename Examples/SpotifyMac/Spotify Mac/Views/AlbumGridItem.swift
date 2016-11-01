import Spots
import Brick
import Sugar

open class AlbumGridItem: NSCollectionViewItem, SpotConfigurable {

  var item: Item?

  open var preferredViewSize: CGSize = CGSize(width: 0, height: 88)
  open var customView = FlippedView().then {
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.alpha(0.5)
    shadow.shadowBlurRadius = 10.0
    shadow.shadowOffset = CGSize(width: 0, height: -10)

    $0.shadow = shadow
  }

  static open var flipped: Bool {
    get {
      return true
    }
  }

  open lazy var titleLabel = NSTextField().then {
    $0.isEditable = false
    $0.isSelectable = false
    $0.isBezeled = false
    $0.textColor = NSColor.white
    $0.drawsBackground = false
    $0.alignment = .center
  }

  lazy var customImageView = NSImageView().then {
    $0.autoresizingMask = .viewWidthSizable
  }

  override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nil, bundle: nil)

    customView.addSubview(customImageView)
    customView.addSubview(titleLabel)

    setupConstraints()
  }

  func setupConstraints() {
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.leftAnchor.constraint(equalTo: customImageView.superview!.leftAnchor).isActive = true
    titleLabel.rightAnchor.constraint(equalTo: customImageView.superview!.rightAnchor).isActive = true
    titleLabel.centerXAnchor.constraint(equalTo: titleLabel.superview!.centerXAnchor).isActive = true
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open override func loadView() {
    view = customView
  }

  open func configure(_ item: inout Item) {
    self.item = item

    customView.frame.size.height = item.size.height
    customImageView.frame.size.width = item.size.width
    customImageView.frame.size.height = item.size.height

    if item.image.isPresent && item.image.hasPrefix("http") {
      customImageView.setImage(url: NSURL(string: item.image) as URL?) { [weak self] image in
        self?.customImageView.contentMode = .scaleToAspectFill
      }
    }
  }
}
