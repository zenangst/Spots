import Spots
import Brick
import Sugar

public class FeaturedGridItem: NSCollectionViewItem, SpotConfigurable {

  var item: ViewModel?

  public var size = CGSize(width: 0, height: 88)
  public var customView = FlippedView().then {
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.blackColor()
    shadow.shadowBlurRadius = 10.0
    shadow.shadowOffset = CGSize(width: 0, height: -10)

    $0.wantsLayer = true
    $0.layer = CALayer()
    $0.layer?.backgroundColor = NSColor(red:0.157, green:0.157, blue:0.157, alpha: 1).CGColor
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
  }

  public lazy var subtitleLabel = NSTextField().then {
    $0.editable = false
    $0.selectable = false
    $0.bezeled = false
    $0.textColor = NSColor.lightGrayColor()
    $0.drawsBackground = false
  }

  public override var selected: Bool {
    didSet {
      if selected {
        customView.layer?.backgroundColor = NSColor(red:0.257, green:0.257, blue:0.257, alpha: 1).CGColor
      } else {
        customView.layer?.backgroundColor = NSColor(red:0.157, green:0.157, blue:0.157, alpha: 1).CGColor
      }
    }
  }

  override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nil, bundle: nil)

    imageView = customImageView

    view.addSubview(titleLabel)
    view.addSubview(subtitleLabel)
    view.addSubview(customImageView)

    addObserver(self, forKeyPath: "imageView.image", options: .New, context: nil)
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    removeObserver(self, forKeyPath: "imageView.image")
  }

  public override func loadView() {
    view = customView
  }

  public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if let item = item,
      image = customImageView.image
      where keyPath == "imageView.image" && item.meta("useAsBackground", type: Bool.self) == true {

      dispatch(queue: .Initiated) {
        let (background, _, _, _) = image.colors()
        dispatch { [weak self] in
          guard let collectionView = self?.collectionView else { return }
          let gradientLayer = CAGradientLayer()

          gradientLayer.colors = [
            background.alpha(0.8).CGColor,
            NSColor.blackColor().CGColor
          ]
          gradientLayer.locations = [0.0, 0.3]
          collectionView.backgroundView?.layer?.insertSublayer(gradientLayer, atIndex: 0)
          gradientLayer.frame.size.width = 3000
          gradientLayer.frame.size.height = collectionView.frame.size.height
          gradientLayer.opacity = 0.2
        }
      }
    }
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

    self.item = item

    if let imageView = imageView where
      item.image.isPresent && item.image.hasPrefix("http") {
      imageView.frame.size.width = item.size.width
      imageView.frame.size.height = item.size.height - 50
      imageView.frame.origin.y = customView.frame.height - imageView.frame.height + 10
      imageView.imageAlignment = .AlignCenter
      imageView.setImage(NSURL(string: item.image))

      titleLabel.frame.origin.y = item.size.height - imageView.frame.size.height - titleLabel.frame.height
      subtitleLabel.frame.origin.y = titleLabel.frame.origin.y - subtitleLabel.frame.size.height
      titleLabel.frame.origin.x = 12.5
      subtitleLabel.frame.origin.x = 12.5
    }
  }

  public override func viewWillLayout() {
    super.viewWillLayout()

    if let imageView = imageView, item = item, layer = imageView.layer, sublayers = layer.sublayers
      where item.image.isPresent && item.image.hasPrefix("http") {
      for sublayer in sublayers {
        sublayer.frame.size = imageView.frame.size
      }
    }
  }
}
