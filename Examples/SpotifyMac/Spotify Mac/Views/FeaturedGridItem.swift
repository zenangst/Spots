import Spots
import Brick
import Sugar

open class FeaturedGridItem: NSCollectionViewItem, SpotConfigurable {

  var item: Item?

  open var preferredViewSize: CGSize = CGSize(width: 0, height: 88)
  open var customView = FlippedView().then {
    $0.wantsLayer = true
    $0.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)

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
    $0.autoresizingMask = .viewWidthSizable
  }

  open lazy var titleLabel = NSTextField().then {
    $0.isEditable = false
    $0.isSelectable = false
    $0.isBezeled = false
    $0.textColor = NSColor.white
    $0.drawsBackground = false
    $0.font = NSFont.systemFont(ofSize: 14)
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

    addObserver(self, forKeyPath: #keyPath(customImageView.image), options: .new, context: nil)

    setupConstraints()
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    removeObserver(self, forKeyPath: #keyPath(customImageView.image))
  }

  func setupConstraints() {
    customView.translatesAutoresizingMaskIntoConstraints = false
    customImageView.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

    customImageView.topAnchor.constraint(equalTo: customImageView.superview!.topAnchor).isActive = true
    customImageView.leftAnchor.constraint(equalTo: customImageView.superview!.leftAnchor).isActive = true
    customImageView.rightAnchor.constraint(equalTo: customImageView.superview!.rightAnchor).isActive = true

    titleLabel.topAnchor.constraint(equalTo: customImageView.bottomAnchor).isActive = true

    subtitleLabel.leftAnchor.constraint(equalTo: customImageView.superview!.leftAnchor).isActive = true
    subtitleLabel.rightAnchor.constraint(equalTo: customImageView.superview!.rightAnchor).isActive = true
    subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
  }

  open override func loadView() {
    view = customView
  }

  open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if let item = item,
      let image = customImageView.image,
      let backgroundView = collectionView.backgroundView,
      let backgroundLayer = backgroundView.layer
      , backgroundLayer.sublayers == nil && keyPath == "customImageView.image" && item.meta("useAsBackground", type: Bool.self) == true {

      dispatch(queue: .interactive) {
        let (background, _, _, _) = image.colors()
        dispatch { [weak self] in
          guard let weakSelf = self else { return }

          let gradientLayer = CAGradientLayer()
          gradientLayer.colors = [
            background.alpha(0.4).cgColor,
            NSColor.clear.cgColor
          ]
          gradientLayer.locations = [0.0, 0.7]
          gradientLayer.frame.size.width = 3000
          gradientLayer.frame.size.height = weakSelf.collectionView.frame.size.height
          backgroundLayer.insertSublayer(gradientLayer, at: 0)

          NSAnimationContext.runAnimationGroup({ context in
            context.duration = 1.0
            gradientLayer.opacity = 0.0
          }) {
            gradientLayer.opacity = 0.4
          }
        }
      }
    }
  }

  open func configure(_ item: inout Item) {
    customView.layer?.anchorPoint = CGPoint(x: 0.0, y: 0.0)
    titleLabel.stringValue = item.title
    subtitleLabel.stringValue = item.subtitle

    self.item = item

    customImageView.heightAnchor.constraint(equalToConstant: item.size.height - 75).isActive = true
    titleLabel.leftAnchor.constraint(equalTo: customImageView.leftAnchor).isActive = true
    titleLabel.rightAnchor.constraint(equalTo: customImageView.rightAnchor).isActive = true

    if item.image.isPresent && item.image.hasPrefix("http") {
      customImageView.setImage(url: NSURL(string: item.image) as URL?) { [customImageView = customImageView] _ in
        customImageView.contentMode = .scaleToAspectFill
      }
    }
  }
}
