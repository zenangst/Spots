import Spots
import Brick

open class HeroGridItem: NSTableRowView, SpotConfigurable {

  open var preferredViewSize: CGSize = CGSize(width: 0, height: 320)
  open var customView = FlippedView()

  open lazy var gradientLayer = CAGradientLayer()

  open lazy var customImageView = NSImageView().then {
    $0.imageScaling = .scaleNone
  }

  open lazy var titleLabel = NSTextField().then {
    $0.isEditable = false
    $0.isSelectable = false
    $0.isBezeled = false
    $0.textColor = NSColor.white
    $0.drawsBackground = false
  }

  open lazy var subtitleLabel = NSTextField().then {
    $0.isEditable = false
    $0.isSelectable = false
    $0.isBezeled = false
    $0.textColor = NSColor.lightGray
    $0.drawsBackground = false
  }

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    addSubview(customImageView)
    addSubview(titleLabel)
    addSubview(subtitleLabel)

    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black
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

    customImageView.widthAnchor.constraint(equalTo: customImageView.superview!.widthAnchor).isActive = true
    customImageView.heightAnchor.constraint(equalTo: customImageView.superview!.heightAnchor).isActive = true

    titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    subtitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: -15).isActive = true
  }

  open func configure(_ item: inout Item) {
    titleLabel.stringValue = item.title
    titleLabel.font = NSFont(name: "Avenir Next", size: 64)
    titleLabel.sizeToFit()

    subtitleLabel.font = NSFont(name: "Avenir Next Condensed", size: 28)
    subtitleLabel.stringValue = item.subtitle.uppercased()
    subtitleLabel.sizeToFit()

    if item.image.isPresent && item.image.hasPrefix("http") {

      gradientLayer.colors = [
        NSColor.clear.cgColor,
        NSColor.black.cgColor
      ]
      gradientLayer.locations = [0.1, 1.0]

      let shadow = NSShadow()
      shadow.shadowOffset = CGSize(width: -20, height: 0)
      shadow.shadowBlurRadius = 20.0
      customImageView.shadow = shadow
      customImageView.setImage(NSURL(string: item.image) as URL?) { [weak self] _ in
        guard let weakSelf = self else { return }
        weakSelf.customImageView.layer?.mask = weakSelf.gradientLayer
      }
    }
  }

  open override func layout() {
    super.layout()

    gradientLayer.frame.size.width = customImageView.frame.size.width * 2
    gradientLayer.frame.size.height = customImageView.frame.size.height
  }
}
