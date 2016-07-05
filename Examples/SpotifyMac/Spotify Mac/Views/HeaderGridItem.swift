import Spots
import Brick
import Sugar

public class HeaderGridItem: NSCollectionViewItem, SpotConfigurable {

  var item: ViewModel?

  public var size = CGSize(width: 0, height: 88)
  public var customView = FlippedView()

  static public var flipped: Bool {
    get {
      return true
    }
  }

  lazy var customImageView = NSImageView().then {
    $0.autoresizingMask = .ViewWidthSizable

    let shadow = NSShadow()
    shadow.shadowColor = NSColor.blackColor().alpha(0.5)
    shadow.shadowBlurRadius = 10.0
    shadow.shadowOffset = CGSize(width: 0, height: -10)

    $0.shadow = shadow
  }

  public lazy var titleLabel = NSTextField().then {
    $0.editable = false
    $0.bezeled = false
    $0.textColor = NSColor.whiteColor()
    $0.drawsBackground = false
    $0.font = NSFont.boldSystemFontOfSize(28)
  }

  public lazy var subtitleLabel = NSTextField().then {
    $0.editable = false
    $0.bezeled = false
    $0.textColor = NSColor.lightGrayColor()
    $0.backgroundColor = NSColor.blackColor()
    $0.drawsBackground = false
  }

  lazy var lineView = NSView().then {
    $0.wantsLayer = true
    $0.layer?.backgroundColor = NSColor.grayColor().colorWithAlphaComponent(0.2).CGColor
  }

  override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nil, bundle: nil)
    customView.addSubview(titleLabel)
    customView.addSubview(subtitleLabel)
    customView.addSubview(customImageView)
    customView.addSubview(lineView)

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
    customImageView.translatesAutoresizingMaskIntoConstraints = false
    lineView.translatesAutoresizingMaskIntoConstraints = false

    customImageView.topAnchor.constraintEqualToAnchor(customView.topAnchor).active = true
    customImageView.widthAnchor.constraintEqualToConstant(160).active = true
    customImageView.heightAnchor.constraintEqualToConstant(160).active = true
    customImageView.leftAnchor.constraintEqualToAnchor(customView.leftAnchor, constant: 10).active = true

    titleLabel.topAnchor.constraintEqualToAnchor(customImageView.topAnchor).active = true
    titleLabel.leftAnchor.constraintEqualToAnchor(customImageView.rightAnchor, constant: 20).active = true
    titleLabel.rightAnchor.constraintEqualToAnchor(titleLabel.superview!.rightAnchor, constant: 10).active = true

    subtitleLabel.leftAnchor.constraintEqualToAnchor(titleLabel.leftAnchor, constant: -4).active = true
    subtitleLabel.rightAnchor.constraintEqualToAnchor(titleLabel.superview!.rightAnchor).active = true
    subtitleLabel.topAnchor.constraintEqualToAnchor(titleLabel.bottomAnchor, constant: 10).active = true

    lineView.heightAnchor.constraintEqualToConstant(1).active = true
    lineView.widthAnchor.constraintEqualToAnchor(lineView.superview!.widthAnchor).active = true
    lineView.bottomAnchor.constraintEqualToAnchor(lineView.superview!.bottomAnchor).active = true
  }

  public func configure(inout item: ViewModel) {
    titleLabel.stringValue = item.title
    subtitleLabel.stringValue = item.subtitle

    if item.image.isPresent && item.image.hasPrefix("http") {
      customImageView.setImage(NSURL(string: item.image)) { [weak self] _ in
        self?.customImageView.contentMode = .ScaleToAspectFill
      }
    }
  }
}
