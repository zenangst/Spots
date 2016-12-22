import Cocoa
import Spots
import Brick

class CompositionListView: NSTableRowView, SpotConfigurable {

  static open var isFlipped: Bool {
    get {
      return true
    }
  }

  open lazy var titleLabel: NSTextField = {
    let label = NSTextField()

    label.isEditable = false
    label.isBezeled = false
    label.textColor = NSColor.black
    label.drawsBackground = false
    
    return label
  }()

  open lazy var subtitleLabel: NSTextField = {
    let label = NSTextField()
    
    label.isEditable = false
    label.isBezeled = false
    label.drawsBackground = false
    label.cell?.wraps = true
    label.cell?.lineBreakMode = .byWordWrapping

    return label
  }()

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    addSubview(titleLabel)
    addSubview(subtitleLabel)
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  var preferredViewSize: CGSize = CGSize(width: 0, height: 44)

  func configure(_ item: inout Item) {
    titleLabel.stringValue = item.title
    subtitleLabel.stringValue = item.subtitle

    titleLabel.sizeToFit()
  }
}
