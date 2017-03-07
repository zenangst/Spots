import Cocoa

open class ListSpotItem: NSTableRowView, ItemConfigurable {

  override open var isFlipped: Bool {
    return true
  }

  open override var isSelected: Bool {
    didSet {
      if isSelected {
        layer?.backgroundColor = NSColor.black.withAlphaComponentModel(0.85).cgColor
      } else {
        layer?.backgroundColor = NSColor.black.cgColor
      }
    }
  }

  open var preferredViewSize = CGSize(width: 0, height: 88)

  lazy var titleLabel: NSTextField = {
    let titleLabel = NSTextField()
    titleLabel.isEditable = false
    titleLabel.isSelectable = false
    titleLabel.isBezeled = false
    titleLabel.textColor = NSColor.white
    titleLabel.drawsBackground = false

    return titleLabel
  }()

  lazy var subtitleLabel: NSTextField = {
    let subtitleLabel = NSTextField()
    subtitleLabel.isEditable = false
    subtitleLabel.isSelectable = false
    subtitleLabel.isBezeled = false
    subtitleLabel.textColor = NSColor.lightGray
    subtitleLabel.drawsBackground = false

    return subtitleLabel
  }()

  lazy var lineView: NSView = {
    let lineView = NSView()
    lineView.frame.size.height = 1
    lineView.wantsLayer = true
    lineView.layer = CALayer()
    lineView.layer?.backgroundColor = NSColor.gray.withAlphaComponentModel(0.4).cgColor
    lineView.autoresizingMask = .viewWidthSizable

    return lineView
  }()

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    wantsLayer = true
    layer = CALayer()
    layer?.backgroundColor = NSColor.black.cgColor

    addSubview(titleLabel)
    addSubview(subtitleLabel)
    addSubview(lineView)
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open func configure( _ item: inout Item) {
    titleLabel.stringValue = item.title
    titleLabel.frame.origin.x = 8

    titleLabel.sizeToFit()
    if !item.subtitle.isEmpty {
      titleLabel.frame.origin.y = 8
      titleLabel.font = NSFont.boldSystemFont(ofSize: 14)
    } else {
      titleLabel.frame.origin.y = item.size.height / 2 - titleLabel.frame.size.height / 2
    }

    subtitleLabel.frame.origin.x = 8
    subtitleLabel.stringValue = item.subtitle
    subtitleLabel.sizeToFit()
    subtitleLabel.frame.origin.y = titleLabel.frame.origin.y + subtitleLabel.frame.height

    lineView.frame.origin.y = item.size.height + 1
  }
}
