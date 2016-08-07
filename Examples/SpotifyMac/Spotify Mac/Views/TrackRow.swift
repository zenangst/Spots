import Cocoa
import Spots
import Brick
import Imaginary
import Hue

public class TrackRow: NSTableRowView, SpotConfigurable {

  public var item: ViewModel?
  public var size = CGSize(width: 0, height: 50)

  public var tintColor: NSColor? {
    get {
      if let hexColor = item?.meta("tintColor", type: String.self) {
        return NSColor.hex(hexColor)
      }

      return nil
    }
  }

  public override var selected: Bool {
    didSet {
      if selected {
        titleLabel.textColor = NSColor.whiteColor()
        durationLabel.textColor = NSColor.whiteColor()
        titleLabel.font = NSFont.boldSystemFontOfSize(12)
        subtitleLabel.textColor = NSColor.whiteColor()
        if tintColor != nil {
          imageView.tintColor = tintColor
        }
        trackLabel.textColor = NSColor.whiteColor()

        let gradientLayer = CAGradientLayer()

        gradientLayer.colors = [
          NSColor(red:0.216, green:0.824, blue:0.278, alpha: 0.75).CGColor,
          NSColor(red:0.216, green:0.824, blue:0.278, alpha: 0.325).CGColor,
        ]

        layer = gradientLayer

        layer?.cornerRadius = 3.0

        if let item = item where !item.image.hasPrefix("http") {
          imageView.tintColor = NSColor.whiteColor()
        }

        playButton.tintColor = NSColor.whiteColor()
      } else {
        titleLabel.font = NSFont.systemFontOfSize(12)
        titleLabel.textColor = NSColor.whiteColor()
        durationLabel.textColor = NSColor.lightGrayColor()
        subtitleLabel.textColor = NSColor.lightGrayColor()
        trackLabel.textColor = NSColor.darkGrayColor()
        if tintColor != nil { imageView.tintColor = NSColor.grayColor() }
        layer = CALayer()
        layer?.backgroundColor = NSColor.clearColor().CGColor
        playButton.tintColor = NSColor.grayColor()
      }
    }
  }

  lazy var imageView: ClickableImageView = ClickableImageView()
  lazy var playButton = NSImageView()

  public lazy var trackLabel = NSTextField().then {
    $0.editable = false
    $0.selectable = false
    $0.bezeled = false
    $0.alignment = .Center
    $0.drawsBackground = false
  }

  public lazy var titleLabel = NSTextField().then {
    $0.editable = false
    $0.selectable = false
    $0.bezeled = false
    $0.drawsBackground = false
  }

  public lazy var subtitleLabel: ClickableTextField = ClickableTextField().then {
    $0.editable = false
    $0.selectable = false
    $0.bezeled = false
    $0.drawsBackground = false
    $0.cell?.wraps = true
    $0.cell?.lineBreakMode = .ByWordWrapping
  }

  public lazy var durationLabel = NSTextField().then {
    $0.editable = false
    $0.selectable = false
    $0.bezeled = false
    $0.drawsBackground = false
    $0.font = NSFont.systemFontOfSize(11)
  }

  lazy var lineView = NSView().then {
    $0.frame.size.height = 1
    $0.wantsLayer = true
    $0.layer = CALayer()
    $0.layer?.backgroundColor = NSColor.grayColor().colorWithAlphaComponent(0.1).CGColor
    $0.autoresizingMask = .ViewWidthSizable
  }

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    selectionHighlightStyle = .None
    backgroundColor = NSColor.clearColor()
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
    imageView.clickType = .Double
    imageView.clickAction = #selector(TrackRow.clickAlbum(_:))
    imageView.enabled = true

    subtitleLabel.target = self
    subtitleLabel.clickType = .Single

    playButton.image = NSImage(named: "playButton")
    playButton.frame.size.width = 40
    playButton.frame.size.height = 40

    setupConstraints()
  }

  public func setupConstraints() {
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    durationLabel.translatesAutoresizingMaskIntoConstraints = false
    playButton.translatesAutoresizingMaskIntoConstraints = false
    trackLabel.translatesAutoresizingMaskIntoConstraints = false
    imageView.translatesAutoresizingMaskIntoConstraints = false
    trackLabel.leftAnchor.constraintEqualToAnchor(trackLabel.superview!.leftAnchor, constant: 10).active = true
    trackLabel.widthAnchor.constraintEqualToConstant(40).active = true
    trackLabel.centerYAnchor.constraintEqualToAnchor(trackLabel.superview!.centerYAnchor).active = true

    titleLabel.leftAnchor.constraintEqualToAnchor(imageView.rightAnchor, constant: 10).active = true
    titleLabel.rightAnchor.constraintEqualToAnchor(titleLabel.superview!.rightAnchor, constant: 10).active = true

    subtitleLabel.leftAnchor.constraintEqualToAnchor(imageView.rightAnchor, constant: 10).active = true
    subtitleLabel.topAnchor.constraintEqualToAnchor(titleLabel.bottomAnchor).active = true

    playButton.rightAnchor.constraintEqualToAnchor(playButton.superview!.rightAnchor, constant: -20).active = true
    playButton.topAnchor.constraintEqualToAnchor(playButton.superview!.topAnchor, constant: 4).active = true

    durationLabel.centerXAnchor.constraintEqualToAnchor(playButton.centerXAnchor).active = true
    durationLabel.topAnchor.constraintEqualToAnchor(playButton.bottomAnchor, constant: 3).active = true

    imageView.leftAnchor.constraintEqualToAnchor(trackLabel.rightAnchor).active = true
    imageView.centerYAnchor.constraintEqualToAnchor(imageView.superview!.centerYAnchor).active = true
  }

  func clickAlbum(sender: NSEvent) {
    guard let item = item else { return }

    AppDelegate.navigate(item.meta("album-urn", ""), fragments: item.meta("album-fragments", [:]))
  }

  func clickArtist(sender: NSEvent) {
    guard let item = item else { return }

    AppDelegate.navigate(item.meta("artist-urn", ""), fragments: item.meta("artist-fragments", [:]))
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func configure(inout item: ViewModel) {
    if item.meta("separator", type: Bool.self) == false {
      lineView.frame.size.height = 0.0
    } else {
      lineView.frame.size.height = 1.0
    }

    trackLabel.stringValue = item.meta("trackNumber", "")
    titleLabel.stringValue = item.title

    let attributedString = NSMutableAttributedString(string: item.subtitle)
    attributedString.addAttribute(NSLinkAttributeName, value: "https://www.hackingwithswift.com", range: NSRange(location: 0, length: item.subtitle.length))
    subtitleLabel.attributedStringValue = attributedString
    subtitleLabel.sizeToFit()
    durationLabel.stringValue = NSTimeInterval(item.meta("duration", 0)).minutesAndSeconds

    if item.subtitle.isPresent {
      titleLabel.centerYAnchor.constraintEqualToAnchor(titleLabel.superview!.centerYAnchor, constant: -10).active = true
    } else {
      titleLabel.centerYAnchor.constraintEqualToAnchor(titleLabel.superview!.centerYAnchor).active = true
    }

    if !item.meta("artist-urn", "").isEmpty {
      subtitleLabel.clickAction = #selector(TrackRow.clickArtist(_:))
    } else {
      subtitleLabel.clickAction = nil
    }

    self.item = item

    if item.image.isPresent && item.image.hasPrefix("http") {
      imageView.heightAnchor.constraintEqualToConstant(40).active = true
      imageView.widthAnchor.constraintEqualToConstant(40).active = true
      imageView.setImage(NSURL(string: item.image))
    } else {
      imageView.image = NSImage(named: item.image)
      imageView.heightAnchor.constraintEqualToConstant(18).active = true
      imageView.widthAnchor.constraintEqualToConstant(18).active = true
      imageView.tintColor = selected ? NSColor.whiteColor() : NSColor.grayColor()
    }

    if item.meta("playing", type: Bool.self) == true {
      playButton.image = NSImage(named: "stopButton")
      playButton.tintColor = NSColor.whiteColor()
    } else {
      playButton.image = NSImage(named: "playButton")
      playButton.tintColor = NSColor.grayColor()
    }

    lineView.frame.origin.y = item.size.height
  }
}
