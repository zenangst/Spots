import Cocoa

open class DefaultItemView: NSTableRowView, ItemConfigurable {

  override open var isFlipped: Bool {
    return true
  }

  open override var isSelected: Bool {
    didSet {
      if isSelected {
        layer?.backgroundColor = NSColor.gray.withAlphaComponent(0.9).cgColor
      } else {
        layer?.backgroundColor = NSColor.white.cgColor
      }
    }
  }

  open var preferredViewSize = Configuration.defaultViewSize

  lazy var titleLabel: NSTextField = {
    let titleLabel = NSTextField()
    titleLabel.isEditable = false
    titleLabel.isSelectable = false
    titleLabel.isBezeled = false
    titleLabel.drawsBackground = false

    return titleLabel
  }()

  lazy var subtitleLabel: NSTextField = {
    let subtitleLabel = NSTextField()
    subtitleLabel.isEditable = false
    subtitleLabel.isSelectable = false
    subtitleLabel.isBezeled = false
    subtitleLabel.textColor = NSColor.black.withAlphaComponent(0.9)
    subtitleLabel.drawsBackground = false

    return subtitleLabel
  }()

  lazy var textLabel: NSTextField = {
    let textLabel = NSTextField()
    textLabel.isEditable = false
    textLabel.isSelectable = false
    textLabel.isBezeled = false
    textLabel.textColor = NSColor.black.withAlphaComponent(0.9)
    textLabel.drawsBackground = false

    return textLabel
  }()

  lazy var lineView: NSView = {
    let lineView = NSView()
    lineView.frame.size.height = 1
    lineView.wantsLayer = true
    lineView.layer = CALayer()
    lineView.layer?.backgroundColor = NSColor.gray.withAlphaComponent(0.4).cgColor
    lineView.autoresizingMask = .viewWidthSizable

    return lineView
  }()

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    wantsLayer = true
    layer = CALayer()
    layer?.backgroundColor = NSColor.white.cgColor

    addSubview(titleLabel)
    addSubview(subtitleLabel)
    addSubview(textLabel)
    addSubview(lineView)

    setupConstraints()
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupConstraints() {
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    textLabel.translatesAutoresizingMaskIntoConstraints = false

    titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
    titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
    titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true

    subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
    subtitleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
    subtitleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true

    textLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8).isActive = true
    textLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
    textLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
  }

  open func configure( _ item: inout Item) {
    titleLabel.stringValue = item.title
    subtitleLabel.stringValue = item.subtitle
    textLabel.stringValue = item.text

    [titleLabel, subtitleLabel, textLabel].forEach {
      $0.sizeToFit()
    }

    let titleLabelSize = titleLabel.sizeThatFits(CGSize(width: item.size.width, height: 0.0))
    let subtitleLabelSize = subtitleLabel.sizeThatFits(CGSize(width: item.size.width, height: 0.0))
    let textLabelSize = textLabel.sizeThatFits(CGSize(width: item.size.width, height: 0.0))

    item.size.height = [titleLabelSize, subtitleLabelSize, textLabelSize].reduce(0, { $0 + $1.height })
    
//    titleLabel.frame.origin.x = 8
//    subtitleLabel.frame.origin.x = 8
//    textLabel.frame.origin.x = 8
//
//    titleLabel.sizeToFit()
//    subtitleLabel.sizeToFit()
//    textLabel.sizeToFit()
//
//    if !item.subtitle.isEmpty {
//      titleLabel.frame.origin.y = item.size.height / 2 - titleLabel.frame.size.height / 2 - subtitleLabel.frame.size.height / 2
//      titleLabel.font = NSFont.boldSystemFont(ofSize: 14)
//    } else {
//      titleLabel.frame.origin.y = item.size.height / 2 - titleLabel.frame.size.height / 2
//    }
//
//    subtitleLabel.frame.origin.y = titleLabel.frame.origin.y + subtitleLabel.frame.height

    lineView.frame.origin.y = item.size.height + 1
  }
}
