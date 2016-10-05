import Cocoa
import Spots
import Brick
import Imaginary
import Hue

open class TrackRow: NSTableRowView, SpotConfigurable {

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
        titleLabel.textColor = NSColor.white
        durationLabel.textColor = NSColor.white
        titleLabel.font = NSFont.boldSystemFont(ofSize: 12)
        subtitleLabel.textColor = NSColor.white
        if tintColor != nil {
          imageView.tintColor = tintColor
        }
        trackLabel.textColor = NSColor.white

        let gradientLayer = CAGradientLayer()

        gradientLayer.colors = [
          NSColor(red:0.216, green:0.824, blue:0.278, alpha: 0.75).cgColor,
          NSColor(red:0.216, green:0.824, blue:0.278, alpha: 0.325).cgColor,
        ]

        layer = gradientLayer

        layer?.cornerRadius = 3.0

        if let item = item , !item.image.hasPrefix("http") {
          imageView.tintColor = NSColor.white
        }

        playButton.tintColor = NSColor.white
      } else {
        titleLabel.font = NSFont.systemFont(ofSize: 12)
        titleLabel.textColor = NSColor.white
        durationLabel.textColor = NSColor.lightGray
        subtitleLabel.textColor = NSColor.lightGray
        trackLabel.textColor = NSColor.darkGray
        if tintColor != nil { imageView.tintColor = NSColor.gray }
        layer = CALayer()
        layer?.backgroundColor = NSColor.clear.cgColor
        playButton.tintColor = NSColor.gray
      }
    }
  }

  lazy var imageView: ClickableImageView = ClickableImageView()
  lazy var playButton = NSImageView()

  open lazy var trackLabel = NSTextField().then {
    $0.isEditable = false
    $0.isSelectable = false
    $0.isBezeled = false
    $0.alignment = .center
    $0.drawsBackground = false
  }

  open lazy var titleLabel = NSTextField().then {
    $0.isEditable = false
    $0.isSelectable = false
    $0.isBezeled = false
    $0.drawsBackground = false
  }

  open lazy var subtitleLabel: ClickableTextField = ClickableTextField().then {
    $0.isEditable = false
    $0.isSelectable = false
    $0.isBezeled = false
    $0.drawsBackground = false
    $0.cell?.wraps = true
    $0.cell?.lineBreakMode = .byWordWrapping
  }

  open lazy var durationLabel = NSTextField().then {
    $0.isEditable = false
    $0.isSelectable = false
    $0.isBezeled = false
    $0.drawsBackground = false
    $0.font = NSFont.systemFont(ofSize: 11)
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
    addSubview(trackLabel)
    addSubview(titleLabel)
    addSubview(subtitleLabel)
    addSubview(durationLabel)
    addSubview(lineView)
    addSubview(imageView)
    addSubview(playButton)

    imageView.target = self
    imageView.clickType = .double
    imageView.clickAction = #selector(TrackRow.clickAlbum(_:))
    imageView.isEnabled = true

    subtitleLabel.target = self
    subtitleLabel.clickType = .single

    playButton.image = NSImage(named: "playButton")
    playButton.frame.size.width = 40
    playButton.frame.size.height = 40

    setupConstraints()
  }

  open func setupConstraints() {
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    durationLabel.translatesAutoresizingMaskIntoConstraints = false
    playButton.translatesAutoresizingMaskIntoConstraints = false
    trackLabel.translatesAutoresizingMaskIntoConstraints = false
    imageView.translatesAutoresizingMaskIntoConstraints = false
    trackLabel.leftAnchor.constraint(equalTo: trackLabel.superview!.leftAnchor, constant: 10).isActive = true
    trackLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true
    trackLabel.centerYAnchor.constraint(equalTo: trackLabel.superview!.centerYAnchor).isActive = true

    titleLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 10).isActive = true
    titleLabel.rightAnchor.constraint(equalTo: titleLabel.superview!.rightAnchor, constant: 10).isActive = true

    subtitleLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 10).isActive = true
    subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true

    playButton.rightAnchor.constraint(equalTo: playButton.superview!.rightAnchor, constant: -20).isActive = true
    playButton.topAnchor.constraint(equalTo: playButton.superview!.topAnchor, constant: 4).isActive = true

    durationLabel.centerXAnchor.constraint(equalTo: playButton.centerXAnchor).isActive = true
    durationLabel.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 3).isActive = true

    imageView.leftAnchor.constraint(equalTo: trackLabel.rightAnchor).isActive = true
    imageView.centerYAnchor.constraint(equalTo: imageView.superview!.centerYAnchor).isActive = true
  }

  func clickAlbum(_ sender: NSEvent) {
    guard let item = item else { return }

    AppDelegate.navigate(item.meta("album-urn", ""), fragments: item.meta("album-fragments", [:]))
  }

  func clickArtist(_ sender: NSEvent) {
    guard let item = item else { return }

    AppDelegate.navigate(item.meta("artist-urn", ""), fragments: item.meta("artist-fragments", [:]))
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open func configure(_ item: inout Item) {
    if item.meta("separator", type: Bool.self) == false {
      lineView.frame.size.height = 0.0
    } else {
      lineView.frame.size.height = 1.0
    }

    trackLabel.stringValue = item.meta("trackNumber", "")
    titleLabel.stringValue = item.title
    subtitleLabel.attributedStringValue = NSAttributedString(string: item.subtitle)
    subtitleLabel.sizeToFit()
    durationLabel.stringValue = TimeInterval(item.meta("duration", 0)).minutesAndSeconds

    if item.subtitle.isPresent {
      titleLabel.centerYAnchor.constraint(equalTo: titleLabel.superview!.centerYAnchor, constant: -10).isActive = true
    } else {
      titleLabel.centerYAnchor.constraint(equalTo: titleLabel.superview!.centerYAnchor).isActive = true
    }

    if !item.meta("artist-urn", "").isEmpty {
      subtitleLabel.clickAction = #selector(TrackRow.clickArtist(_:))
    } else {
      subtitleLabel.clickAction = nil
    }

    self.item = item

    if item.image.isPresent && item.image.hasPrefix("http") {
      imageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
      imageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
      imageView.setImage(URL(string: item.image))
    } else {
      imageView.image = NSImage(named: item.image)
      imageView.heightAnchor.constraint(equalToConstant: 18).isActive = true
      imageView.widthAnchor.constraint(equalToConstant: 18).isActive = true
      imageView.tintColor = isSelected ? NSColor.white : NSColor.gray
    }

    if item.meta("playing", type: Bool.self) == true {
      playButton.image = NSImage(named: "stopButton")
      playButton.tintColor = NSColor.white
    } else {
      playButton.image = NSImage(named: "playButton")
      playButton.tintColor = NSColor.gray
    }

    lineView.frame.origin.y = item.size.height
  }
}
