import Cocoa
import Brick

open class GridView: View, SpotConfigurable {

  open var preferredViewSize = CGSize(width: 88, height: 88)
  open var customView = FlippedView()

  open lazy var imageView: NSImageView = {
    let imageView = NSImageView()
    imageView.autoresizingMask = .viewWidthSizable

    return imageView
  }()

  open lazy var titleLabel: NSTextField = {
    let titleLabel = NSTextField()
    titleLabel.isEditable = false
    titleLabel.isSelectable = false
    titleLabel.isBezeled = false
    titleLabel.textColor = NSColor.white
    titleLabel.drawsBackground = false

    return titleLabel
  }()

  open lazy var subtitleLabel: NSTextField = {
    let subtitleLabel = NSTextField()
    subtitleLabel.isEditable = false
    subtitleLabel.isSelectable = false
    subtitleLabel.isBezeled = false
    subtitleLabel.textColor = NSColor.lightGray
    subtitleLabel.drawsBackground = false

    return subtitleLabel
  }()

  override init(frame rect: CGRect) {
    super.init(frame: rect)
    wantsLayer = true
    layer?.backgroundColor = NSColor.clear.cgColor

    addSubview(imageView)
    addSubview(titleLabel)
    addSubview(subtitleLabel)
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open func configure( _ item: inout Item) {
    titleLabel.stringValue = item.title
    titleLabel.frame.origin.x = 8
    titleLabel.sizeToFit()
    if !item.subtitle.isEmpty {
      titleLabel.frame.origin.y = 8
      titleLabel.font = NSFont.boldSystemFont(ofSize: 14)
      titleLabel.sizeToFit()
    } else {
      titleLabel.frame.origin.y = item.size.height / 2 - titleLabel.frame.size.height / 2
    }

    subtitleLabel.frame.origin.x = 8
    subtitleLabel.stringValue = item.subtitle
    subtitleLabel.sizeToFit()
    subtitleLabel.frame.origin.y = titleLabel.frame.origin.y + subtitleLabel.frame.height
  }
}
