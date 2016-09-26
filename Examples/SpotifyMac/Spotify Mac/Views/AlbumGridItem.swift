import Spots
import Brick
import Sugar

public class AlbumGridItem: NSCollectionViewItem, SpotConfigurable {

  var item: Item?

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

  public lazy var titleLabel = NSTextField().then {
    $0.editable = false
    $0.selectable = false
    $0.bezeled = false
    $0.textColor = NSColor.whiteColor()
    $0.drawsBackground = false
    $0.alignment = .Center
  }

  lazy var customImageView = NSImageView().then {
    $0.autoresizingMask = .ViewWidthSizable
  }

  override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nil, bundle: nil)

    customView.addSubview(customImageView)
    customView.addSubview(titleLabel)

    setupConstraints()
  }

  func setupConstraints() {
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.leftAnchor.constraintEqualToAnchor(customImageView.superview!.leftAnchor).active = true
    titleLabel.rightAnchor.constraintEqualToAnchor(customImageView.superview!.rightAnchor).active = true
    titleLabel.centerXAnchor.constraintEqualToAnchor(titleLabel.superview!.centerXAnchor).active = true
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func loadView() {
    view = customView
  }

  public func configure(inout item: Item) {
    self.item = item

    customView.frame.size.height = item.size.height
    customImageView.frame.size.width = item.size.width
    customImageView.frame.size.height = item.size.height

    if item.image.isPresent && item.image.hasPrefix("http") {
      customImageView.setImage(NSURL(string: item.image)) { [weak self] image in
        self?.customImageView.contentMode = .ScaleToAspectFill
      }
    }
  }
}
