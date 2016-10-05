import Spots
import Brick
import Sugar

open class ArtistGridItem: NSCollectionViewItem, SpotConfigurable {

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

  lazy var customImageView = NSImageView().then {
    $0.imageScaling = .scaleNone
    $0.wantsLayer = true
    $0.layer?.cornerRadius = 60
  }

  open lazy var titleLabel = NSTextField().then {
    $0.isEditable = false
    $0.isSelectable = false
    $0.isBezeled = false
    $0.textColor = NSColor.white
    $0.drawsBackground = false
    $0.alignment = .center
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

    customView.addSubview(titleLabel)
    customView.addSubview(subtitleLabel)
    customView.addSubview(customImageView)

    customView.layer?.backgroundColor = NSColor(red:0.357, green:0.357, blue:0.357, alpha: 1).cgColor

    setupConstraints()
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupConstraints() {
    customView.translatesAutoresizingMaskIntoConstraints = false
    customImageView.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

    customImageView.centerXAnchor.constraint(equalTo: customImageView.superview!.centerXAnchor).isActive = true
    customImageView.topAnchor.constraint(equalTo: customImageView.superview!.topAnchor).isActive = true

    titleLabel.leftAnchor.constraint(equalTo: customImageView.superview!.leftAnchor).isActive = true
    titleLabel.rightAnchor.constraint(equalTo: customImageView.superview!.rightAnchor).isActive = true
    titleLabel.topAnchor.constraint(equalTo: customImageView.bottomAnchor, constant: 10).isActive = true

    subtitleLabel.leftAnchor.constraint(equalTo: customImageView.superview!.leftAnchor).isActive = true
    subtitleLabel.rightAnchor.constraint(equalTo: customImageView.superview!.rightAnchor).isActive = true
    subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
  }

  open override func loadView() {
    view = customView
  }

  open func configure(_ item: inout Item) {
    titleLabel.stringValue = item.title
    subtitleLabel.stringValue = item.subtitle

    self.item = item

    customImageView.heightAnchor.constraint(equalToConstant: item.size.height - 40).isActive = true
    customImageView.widthAnchor.constraint(equalToConstant: item.size.width - 40).isActive = true
    customImageView.layer?.cornerRadius = (item.size.width - 40) / 2

    if item.image.isPresent && item.image.hasPrefix("http") {
      customImageView.setImage(NSURL(string: item.image) as URL?) { [weak self] image in
        self?.customImageView.contentMode = .scaleToAspectFill
      }
    }
  }
}
