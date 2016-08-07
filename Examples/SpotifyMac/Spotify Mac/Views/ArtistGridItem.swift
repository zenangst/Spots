import Spots
import Brick
import Sugar

public class ArtistGridItem: NSCollectionViewItem, SpotConfigurable {

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
    $0.imageScaling = .ScaleNone
    $0.wantsLayer = true
    $0.layer?.cornerRadius = 60
  }

  public lazy var titleLabel = NSTextField().then {
    $0.editable = false
    $0.selectable = false
    $0.bezeled = false
    $0.textColor = NSColor.whiteColor()
    $0.drawsBackground = false
    $0.alignment = .Center
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

    customView.layer?.backgroundColor = NSColor(red:0.357, green:0.357, blue:0.357, alpha: 1).CGColor

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

    customImageView.centerXAnchor.constraintEqualToAnchor(customImageView.superview!.centerXAnchor).active = true
    customImageView.topAnchor.constraintEqualToAnchor(customImageView.superview!.topAnchor).active = true

    titleLabel.leftAnchor.constraintEqualToAnchor(customImageView.superview!.leftAnchor).active = true
    titleLabel.rightAnchor.constraintEqualToAnchor(customImageView.superview!.rightAnchor).active = true
    titleLabel.topAnchor.constraintEqualToAnchor(customImageView.bottomAnchor, constant: 10).active = true

    subtitleLabel.leftAnchor.constraintEqualToAnchor(customImageView.superview!.leftAnchor).active = true
    subtitleLabel.rightAnchor.constraintEqualToAnchor(customImageView.superview!.rightAnchor).active = true
    subtitleLabel.topAnchor.constraintEqualToAnchor(titleLabel.bottomAnchor).active = true
  }

  public override func loadView() {
    view = customView
  }

  public func configure(inout item: ViewModel) {
    titleLabel.stringValue = item.title
    subtitleLabel.stringValue = item.subtitle

    self.item = item

    customImageView.heightAnchor.constraintEqualToConstant(item.size.height - 40).active = true
    customImageView.widthAnchor.constraintEqualToConstant(item.size.width - 40).active = true
    customImageView.layer?.cornerRadius = (item.size.width - 40) / 2

    if item.image.isPresent && item.image.hasPrefix("http") {
      customImageView.setImage(NSURL(string: item.image)) { [weak self] image in
        self?.customImageView.contentMode = .ScaleToAspectFill
      }
    }
  }
}
