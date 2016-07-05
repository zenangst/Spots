import Spots
import Brick
import Sugar

public class FeaturedGridItem: NSCollectionViewItem, SpotConfigurable {

  var item: ViewModel?

  public var size = CGSize(width: 0, height: 88)
  public var customView = FlippedView().then {
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.blackColor().alpha(0.5)
    shadow.shadowBlurRadius = 10.0
    shadow.shadowOffset = CGSize(width: 0, height: -10)
    $0.shadow = shadow
  }

  static public var flipped: Bool {
    get {
      return true
    }
  }

  lazy var customImageView = NSImageView().then {
    $0.autoresizingMask = .ViewWidthSizable
  }

  public lazy var titleLabel = NSTextField().then {
    $0.editable = false
    $0.selectable = false
    $0.bezeled = false
    $0.textColor = NSColor.whiteColor()
    $0.drawsBackground = false
    $0.cell?.wraps = true
    $0.cell?.lineBreakMode = .ByClipping
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

    customView.addSubview(titleLabel)
    customView.addSubview(subtitleLabel)
    customView.addSubview(customImageView)

    addObserver(self, forKeyPath: "customImageView.image", options: .New, context: nil)

    setupConstraints()
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    removeObserver(self, forKeyPath: "customImageView.image")
  }

  func setupConstraints() {
    customView.translatesAutoresizingMaskIntoConstraints = false
    customImageView.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

    customImageView.topAnchor.constraintEqualToAnchor(customImageView.superview!.topAnchor).active = true
    customImageView.leftAnchor.constraintEqualToAnchor(customImageView.superview!.leftAnchor).active = true
    customImageView.rightAnchor.constraintEqualToAnchor(customImageView.superview!.rightAnchor).active = true

    titleLabel.leftAnchor.constraintEqualToAnchor(titleLabel.superview!.leftAnchor).active = true
    titleLabel.rightAnchor.constraintEqualToAnchor(titleLabel.superview!.rightAnchor).active = true
    titleLabel.topAnchor.constraintEqualToAnchor(titleLabel.bottomAnchor).active = true

    subtitleLabel.leftAnchor.constraintEqualToAnchor(customImageView.superview!.leftAnchor).active = true
    subtitleLabel.rightAnchor.constraintEqualToAnchor(customImageView.superview!.rightAnchor).active = true
    subtitleLabel.topAnchor.constraintEqualToAnchor(titleLabel.bottomAnchor).active = true
  }

  public override func loadView() {
    view = customView
  }

  public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if let item = item,
      image = customImageView.image
      where keyPath == "customImageView.image" && item.meta("useAsBackground", type: Bool.self) == true {

      dispatch(queue: .Interactive) {
        let (background, _, _, _) = image.colors()
        dispatch { [weak self] in
          guard let collectionView = self?.collectionView,
            backgroundView = collectionView.backgroundView,
            backgroundLayer = backgroundView.layer
            where backgroundLayer.sublayers == nil
          else { return }
          let gradientLayer = CAGradientLayer()

          gradientLayer.colors = [
            background.alpha(0.4).CGColor,
            NSColor.clearColor().CGColor
          ]
          gradientLayer.locations = [0.0, 0.7]
          gradientLayer.frame.size.width = 3000
          gradientLayer.frame.size.height = collectionView.frame.size.height
          gradientLayer.opacity = 0.4
          backgroundLayer.insertSublayer(gradientLayer, atIndex: 0)
        }
      }
    }
  }

  public func configure(inout item: ViewModel) {
    titleLabel.stringValue = item.title
    subtitleLabel.stringValue = item.subtitle

    self.item = item

    if item.image.isPresent && item.image.hasPrefix("http") {
      customImageView.setImage(NSURL(string: item.image))
    }
  }
}
