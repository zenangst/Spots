import Spots
import Brick

public class HeroGridItem: NSTableRowView, SpotConfigurable {

  public var size = CGSize(width: 0, height: 320)
  public var customView = FlippedView()

  public lazy var gradientLayer = CAGradientLayer()

  public lazy var customImageView = NSImageView().then {
    $0.imageScaling = .ScaleNone
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

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    addSubview(customImageView)
    addSubview(titleLabel)
    addSubview(subtitleLabel)

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
        weakSelf.customImageView.layer?.mask = weakSelf.gradientLayer
      }
    }
  }

  public override func layout() {
    super.layout()

    gradientLayer.frame.size.width = customImageView.frame.size.width * 2
    gradientLayer.frame.size.height = customImageView.frame.size.height
  }
}
