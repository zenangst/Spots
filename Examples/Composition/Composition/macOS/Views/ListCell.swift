import Cocoa
import Spots
import Brick
import Imaginary
import Hue

open class ListCell: NSTableRowView, SpotConfigurable {

  open var item: Item?
  open var preferredViewSize: CGSize = CGSize(width: 0, height: 50)

  open var tintColor: NSColor? {
    get {
      if let hexColor = item?.meta("tintColor", type: String.self) {
        return NSColor(hex: hexColor)
      }

      return nil
    }
  }

  open override var isSelected: Bool {
    didSet {
      if isSelected {
        titleLabel.textColor = tintColor
        subtitleLabel.textColor = tintColor
        if tintColor != nil {
          imageView.tintColor = tintColor
        }
        layer?.backgroundColor = NSColor(red:0.1, green:0.1, blue:0.1, alpha: 0.985).cgColor
      } else {
        titleLabel.textColor = NSColor.lightGray
        subtitleLabel.textColor = NSColor.darkGray
        if tintColor != nil { imageView.tintColor = NSColor.gray }
        layer?.backgroundColor = NSColor.clear.cgColor
        self.shadow = nil
      }
    }
  }

  lazy var imageView = NSImageView()

  open lazy var titleLabel = NSTextField().then {
    $0.isEditable = false
    $0.isBezeled = false
    $0.textColor = NSColor.white
    $0.drawsBackground = false
  }

  open lazy var subtitleLabel = NSTextField().then {
    $0.isEditable = false
    $0.isBezeled = false
    $0.drawsBackground = false
    $0.cell?.wraps = true
    $0.cell?.lineBreakMode = .byWordWrapping
  }

  lazy var lineView = NSView().then {
    $0.frame.size.height = 1
    $0.wantsLayer = true
    $0.layer = CALayer()
    $0.layer?.backgroundColor = NSColor.gray.withAlphaComponent(0.1).cgColor
    $0.autoresizingMask = .viewWidthSizable
  }

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    selectionHighlightStyle = .none
    backgroundColor = NSColor.clear
    wantsLayer = true
    layer = CALayer()
    addSubview(titleLabel)
    addSubview(subtitleLabel)
    addSubview(lineView)
    addSubview(imageView)

    setupConstraints()
  }

  override open func hitTest(_ aPoint: NSPoint) -> NSView? {
    return nil
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open func setupConstraints() {
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

    titleLabel.leftAnchor.constraint(equalTo: titleLabel.superview!.leftAnchor, constant: 52).isActive = true
    titleLabel.rightAnchor.constraint(equalTo: titleLabel.superview!.rightAnchor, constant: -10).isActive = true
    titleLabel.topAnchor.constraint(equalTo: titleLabel.superview!.centerYAnchor, constant: -20).isActive = true
    subtitleLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor).isActive = true
    subtitleLabel.rightAnchor.constraint(equalTo: titleLabel.superview!.rightAnchor, constant: -10).isActive = true
    subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
  }

  open func configure(_ item: inout Item) {
    if item.meta("separator", type: Bool.self) == false {
      lineView.frame.size.height = 0.0
    } else {
      lineView.frame.size.height = 1.0
    }

    titleLabel.stringValue = item.title
    subtitleLabel.stringValue = item.subtitle

    if item.subtitle.isPresent {
      titleLabel.font = NSFont.boldSystemFont(ofSize: 12)
    } else {
      titleLabel.font = NSFont.systemFont(ofSize: 12)
    }

    self.item = item

    if item.image.isPresent {
      titleLabel.frame.origin.x = 50

      if item.image.hasPrefix("http") {
        imageView.frame.size.width = 40
        imageView.frame.size.height = 40
        imageView.frame.origin.x = 5
        imageView.frame.origin.y = item.size.height / 2 - imageView.frame.size.height / 2

        imageView.setImage(url: URL(string: item.image))
      } else {
        imageView.image = NSImage(named: item.image)
        imageView.frame.size.width = 18
        imageView.frame.size.height = 18
        imageView.frame.origin.x = 10
        imageView.frame.origin.y = item.size.height / 2 - imageView.frame.size.height / 2 + 1
        if tintColor != nil {
          imageView.tintColor = NSColor.gray
        }
      }
    }
    
    lineView.frame.origin.y = item.size.height
  }
}
