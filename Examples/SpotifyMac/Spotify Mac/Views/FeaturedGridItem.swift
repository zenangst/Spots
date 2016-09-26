import Spots
import Brick
import Sugar

public class FeaturedGridItem: NSCollectionViewItem, SpotConfigurable {

  var item: Item?

  public var size = CGSize(width: 0, height: 88)
  public var customView = FlippedView().then {
    $0.wantsLayer = true
    $0.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)

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
    $0.font = NSFont.systemFontOfSize(14)
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

    let area = NSTrackingArea(rect: customView.bounds, options: [.InVisibleRect, .MouseEnteredAndExited, .ActiveInKeyWindow], owner: self, userInfo: nil)
    customView.addTrackingArea(area)

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

    titleLabel.topAnchor.constraintEqualToAnchor(customImageView.bottomAnchor).active = true

    subtitleLabel.leftAnchor.constraintEqualToAnchor(customImageView.superview!.leftAnchor).active = true
    subtitleLabel.rightAnchor.constraintEqualToAnchor(customImageView.superview!.rightAnchor).active = true
    subtitleLabel.topAnchor.constraintEqualToAnchor(titleLabel.bottomAnchor).active = true
  }

  public override func loadView() {
    view = customView
  }

  public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if let item = item,
      image = customImageView.image,
      backgroundView = collectionView.backgroundView,
      backgroundLayer = backgroundView.layer
      where backgroundLayer.sublayers == nil && keyPath == "customImageView.image" && item.meta("useAsBackground", type: Bool.self) == true {

      dispatch(queue: .Interactive) {
        let (background, _, _, _) = image.colors()
        dispatch { [weak self] in
          guard let weakSelf = self else { return }

          let gradientLayer = CAGradientLayer()
          gradientLayer.colors = [
            background.alpha(0.4).CGColor,
            NSColor.clearColor().CGColor
          ]
          gradientLayer.locations = [0.0, 0.7]
          gradientLayer.frame.size.width = 3000
          gradientLayer.frame.size.height = weakSelf.collectionView.frame.size.height
          backgroundLayer.insertSublayer(gradientLayer, atIndex: 0)

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

  public override func mouseEntered(theEvent: NSEvent) {
    super.mouseEntered(theEvent)

    guard customView.layer?.animationForKey("animationGroup") == nil else { return }

    let animationGroup = CAAnimationGroup()
    animationGroup.duration = 0.10
    animationGroup.removedOnCompletion = false
    animationGroup.fillMode = kCAFillModeForwards

    let zoomInAnimation = CABasicAnimation(keyPath: "transform.scale")
    zoomInAnimation.fromValue = 1.0
    zoomInAnimation.toValue = 1.1

    let positionAnimation = CABasicAnimation(keyPath: "position")
    let newValue = NSValue(point: CGPoint(
      x: customView.frame.origin.x + customView.frame.size.width / 2,
      y: customView.frame.origin.y + customView.frame.size.height / 2))
    positionAnimation.fromValue = newValue
    positionAnimation.toValue = newValue

    animationGroup.animations = [zoomInAnimation, positionAnimation]

    customView.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    customView.layer?.addAnimation(animationGroup, forKey: "animationGroup")
  }

  public override func mouseExited(theEvent: NSEvent) {
    super.mouseExited(theEvent)

    guard customView.layer?.animationKeys() != nil else { return }

    let animationGroup = CAAnimationGroup()
    animationGroup.duration = 0.10
    animationGroup.removedOnCompletion = false
    animationGroup.fillMode = kCAFillModeForwards

    let zoomInAnimation = CABasicAnimation(keyPath: "transform.scale")
    zoomInAnimation.fromValue = 1.1
    zoomInAnimation.toValue = 1.0

    let positionAnimation = CABasicAnimation(keyPath: "position")
    let newValue = NSValue(point: CGPoint(
      x: customView.frame.origin.x + customView.frame.size.width / 2,
      y: customView.frame.origin.y + customView.frame.size.height / 2))
    positionAnimation.fromValue = newValue
    positionAnimation.toValue = newValue

    animationGroup.animations = [zoomInAnimation, positionAnimation]
    customView.layer?.removeAnimationForKey("animationGroup")
    customView.layer?.addAnimation(animationGroup, forKey: "reverseAnimation")
  }

  public func configure(inout item: Item) {
    customView.layer?.anchorPoint = CGPoint(x: 0.0, y: 0.0)
    titleLabel.stringValue = item.title
    subtitleLabel.stringValue = item.subtitle

    self.item = item

    customImageView.heightAnchor.constraintEqualToConstant(item.size.height - 75).active = true
    titleLabel.leftAnchor.constraintEqualToAnchor(customImageView.leftAnchor).active = true
    titleLabel.rightAnchor.constraintEqualToAnchor(customImageView.rightAnchor).active = true

    if item.image.isPresent && item.image.hasPrefix("http") {
      customImageView.setImage(NSURL(string: item.image)) { [customImageView = customImageView] _ in
        customImageView.contentMode = .ScaleToAspectFill
      }
    }
  }
}
