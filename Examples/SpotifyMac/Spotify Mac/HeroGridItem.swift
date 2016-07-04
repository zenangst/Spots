import Spots
import Brick

public class HeroGridItem: NSCollectionViewItem, SpotConfigurable {

  public var size = CGSize(width: 0, height: 320)
  public var customView = FlippedView()

  public lazy var customImageView = NSImageView()

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

    let shadow = NSShadow()
    shadow.shadowColor = NSColor.blackColor()
    shadow.shadowOffset = CGSize(width: 1, height: 10)
    shadow.shadowBlurRadius = 20.0
    titleLabel.shadow = shadow
    subtitleLabel.shadow = shadow

    setupConstraints()
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func loadView() {
    view = customView
  }

  func setupConstraints() {
    customImageView.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

    customImageView.widthAnchor.constraintEqualToAnchor(customImageView.superview!.widthAnchor).active = true
    customImageView.heightAnchor.constraintEqualToAnchor(customImageView.superview!.heightAnchor).active = true

    titleLabel.leftAnchor.constraintEqualToAnchor(titleLabel.superview!.leftAnchor, constant: 30).active = true
    titleLabel.bottomAnchor.constraintEqualToAnchor(subtitleLabel.topAnchor).active = true
    subtitleLabel.leftAnchor.constraintEqualToAnchor(subtitleLabel.superview!.leftAnchor, constant: 30).active = true
    subtitleLabel.bottomAnchor.constraintEqualToAnchor(subtitleLabel.superview!.bottomAnchor, constant: -30).active = true
  }

  public func configure(inout item: ViewModel) {
    titleLabel.stringValue = item.title
    titleLabel.font = NSFont.systemFontOfSize(28)
    titleLabel.sizeToFit()

    subtitleLabel.font = NSFont.boldSystemFontOfSize(64)
    subtitleLabel.stringValue = item.subtitle.uppercaseString
    subtitleLabel.sizeToFit()

    if item.image.isPresent && item.image.hasPrefix("http") {
      let gradientLayer = CAGradientLayer()

      gradientLayer.colors = [
        NSColor.clearColor().CGColor,
        NSColor.blackColor().CGColor
      ]
      gradientLayer.locations = [0.1, 1.0]

      let shadow = NSShadow()
      shadow.shadowOffset = CGSize(width: -20, height: 0)
      shadow.shadowBlurRadius = 20.0
      customImageView.shadow = shadow
      customImageView.setImage(NSURL(string: item.image)) { [weak self] _ in
        guard let weakSelf = self else { return }
        gradientLayer.frame.size.width = weakSelf.customImageView.frame.size.width
        gradientLayer.frame.size.height = weakSelf.customImageView.frame.size.height
        weakSelf.customImageView.layer?.mask = gradientLayer
      }
    }
  }
}
