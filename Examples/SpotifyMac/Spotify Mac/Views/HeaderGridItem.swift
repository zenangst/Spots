import Spots
import Brick
import Sugar

public class HeaderGridItem: NSTableRowView, SpotConfigurable {

  var item: Item?

  public var size = CGSize(width: 0, height: 88)
  public var containerView = FlippedView()

  static public var flipped: Bool {
    get {
      return true
    }
  }

  lazy var customImageView = NSImageView().then {
    $0.autoresizingMask = .ViewWidthSizable

    let shadow = NSShadow()
    shadow.shadowColor = NSColor.blackColor().alpha(0.6)
    shadow.shadowBlurRadius = 10.0
    shadow.shadowOffset = CGSize(width: 0, height: -4)

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
    $0.font = NSFont.systemFontOfSize(14)
    $0.drawsBackground = false
  }

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    containerView.addSubview(titleLabel)
    containerView.addSubview(subtitleLabel)
    containerView.addSubview(customImageView)

    addObserver(self, forKeyPath: "customImageView.image", options: .New, context: nil)
    addSubview(containerView)

    setupConstraints()
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    removeObserver(self, forKeyPath: "customImageView.image")
  }

  public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if let image = customImageView.image where keyPath == "customImageView.image" {

      dispatch(queue: .Interactive) {
        let (background, _, _, _) = image.colors()
        dispatch {
          guard let appDelegate = NSApplication.sharedApplication().delegate as? AppDelegate else {
            return
          }

          let gradientLayer = CAGradientLayer()

          gradientLayer.colors = [
            NSColor.clearColor().CGColor,
            background.alpha(0.4).CGColor,
          ]
          gradientLayer.locations = [0.0, 1.0]
          gradientLayer.frame.size.width = 3000
          gradientLayer.frame.size.height = appDelegate.mainWindowController?.currentController?.view.frame.size.height ?? 0

          appDelegate.mainWindowController?.currentController?.removeGradientSublayers()
          appDelegate.mainWindowController?.currentController?.view.layer?.insertSublayer(gradientLayer, atIndex: 0)

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

  func setupConstraints() {
    containerView.translatesAutoresizingMaskIntoConstraints = false
    customImageView.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    customImageView.translatesAutoresizingMaskIntoConstraints = false

    containerView.topAnchor.constraintEqualToAnchor(topAnchor).active = true
    containerView.leftAnchor.constraintEqualToAnchor(leftAnchor, constant: 24).active = true
    containerView.rightAnchor.constraintEqualToAnchor(rightAnchor, constant: -24).active = true
    containerView.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true

    customImageView.topAnchor.constraintEqualToAnchor(containerView.topAnchor).active = true
    customImageView.widthAnchor.constraintEqualToConstant(120).active = true
    customImageView.heightAnchor.constraintEqualToConstant(120).active = true
    customImageView.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor, constant: 15).active = true

    titleLabel.topAnchor.constraintEqualToAnchor(customImageView.topAnchor).active = true
    titleLabel.leftAnchor.constraintEqualToAnchor(customImageView.rightAnchor, constant: 20).active = true
    titleLabel.rightAnchor.constraintEqualToAnchor(titleLabel.superview!.rightAnchor, constant: 10).active = true

    subtitleLabel.leftAnchor.constraintEqualToAnchor(titleLabel.leftAnchor).active = true
    subtitleLabel.rightAnchor.constraintEqualToAnchor(titleLabel.superview!.rightAnchor).active = true
    subtitleLabel.topAnchor.constraintEqualToAnchor(titleLabel.bottomAnchor, constant: 10).active = true
  }

  public func configure(inout item: Item) {
    self.item = item

    titleLabel.stringValue = item.title
    subtitleLabel.stringValue = item.subtitle

    if item.image.isPresent && item.image.hasPrefix("http") {
      customImageView.setImage(NSURL(string: item.image)) { [weak self] image in
        self?.customImageView.contentMode = .ScaleToAspectFill
      }
    }
  }
}
