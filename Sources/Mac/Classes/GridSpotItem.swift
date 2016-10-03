import Cocoa
import Brick

open class FlippedView: NSView {
  static open var flipped: Bool {
    get {
      return true
    }
  }
}

open class GridSpotItem: NSCollectionViewItem, SpotConfigurable {

  static open var flipped: Bool {
    get {
      return true
    }
  }

  open override var isSelected: Bool {
    didSet {
      if isSelected {
        view.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.85).cgColor
      } else {
        view.layer?.backgroundColor = NSColor.clear.cgColor
      }
    }
  }

  open var preferredViewSize = CGSize(width: 0, height: 88)
  open var customView = FlippedView()

  open lazy var customImageView: NSImageView = {
    let customImageView = NSImageView()
    customImageView.autoresizingMask = .viewWidthSizable

    return customImageView
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

  override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nil, bundle: nil)

    imageView = customImageView

    view.addSubview(customImageView)
    view.addSubview(titleLabel)
    view.addSubview(subtitleLabel)
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open override func loadView() {
    view = customView
  }

  override open func viewDidLoad() {
    view.wantsLayer = true
    view.layer?.backgroundColor = NSColor.clear.cgColor
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
