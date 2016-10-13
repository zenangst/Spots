import Spots
import Brick
import Sugar

open class HeaderGridItem: NSTableRowView, SpotConfigurable {
  var item: Item?

  open var preferredViewSize: CGSize = CGSize(width: 0, height: 88)
  open var containerView = FlippedView()

  static open var flipped: Bool {
    get {
      return true
    }
  }

  lazy var customImageView = NSImageView().then {
    $0.autoresizingMask = .viewWidthSizable

    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.alpha(0.6)
    shadow.shadowBlurRadius = 10.0
    shadow.shadowOffset = CGSize(width: 0, height: -4)

    $0.shadow = shadow
  }

  open lazy var titleLabel = NSTextField().then {
    $0.isEditable = false
    $0.isBezeled = false
    $0.textColor = NSColor.white
    $0.drawsBackground = false
    $0.font = NSFont.boldSystemFont(ofSize: 28)
  }

  open lazy var subtitleLabel = NSTextField().then {
    $0.isEditable = false
    $0.isBezeled = false
    $0.textColor = NSColor.lightGray
    $0.backgroundColor = NSColor.black
    $0.font = NSFont.systemFont(ofSize: 14)
    $0.drawsBackground = false
  }

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    containerView.addSubview(titleLabel)
    containerView.addSubview(subtitleLabel)
    containerView.addSubview(customImageView)

    addObserver(self, forKeyPath: #keyPath(customImageView.image), options: .new, context: nil)
    addSubview(containerView)

    setupConstraints()
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    removeObserver(self, forKeyPath: #keyPath(customImageView.image))
  }

  open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if let image = customImageView.image , keyPath == #keyPath(customImageView.image) {
      dispatch(queue: .interactive) {
        let (background, _, _, _) = image.colors()
        dispatch {
          guard let appDelegate = NSApplication.shared().delegate as? AppDelegate else {
            return
          }

          let gradientLayer = CAGradientLayer()

          gradientLayer.colors = [
            NSColor.clear.cgColor,
            background.alpha(0.4).cgColor,
          ]
          gradientLayer.locations = [0.0, 1.0]
          gradientLayer.frame.size.width = 3000
          gradientLayer.frame.size.height = appDelegate.mainWindowController?.currentController?.view.frame.size.height ?? 0

          appDelegate.mainWindowController?.currentController?.removeGradientSublayers()
          appDelegate.mainWindowController?.currentController?.view.layer?.insertSublayer(gradientLayer, at: 0)

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

    containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    containerView.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
    containerView.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
    containerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

    customImageView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
    customImageView.widthAnchor.constraint(equalToConstant: 120).isActive = true
    customImageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
    customImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 15).isActive = true

    titleLabel.topAnchor.constraint(equalTo: customImageView.topAnchor).isActive = true
    titleLabel.leftAnchor.constraint(equalTo: customImageView.rightAnchor, constant: 20).isActive = true
    titleLabel.rightAnchor.constraint(equalTo: titleLabel.superview!.rightAnchor, constant: 10).isActive = true

    subtitleLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor).isActive = true
    subtitleLabel.rightAnchor.constraint(equalTo: titleLabel.superview!.rightAnchor).isActive = true
    subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
  }

  open func configure(_ item: inout Item) {
    self.item = item

    titleLabel.stringValue = item.title
    subtitleLabel.stringValue = item.subtitle

    if item.image.isPresent && item.image.hasPrefix("http") {
      customImageView.setImage(NSURL(string: item.image) as URL?) { [weak self] image in
        self?.customImageView.contentMode = .scaleToAspectFill
      }
    }
  }
}
