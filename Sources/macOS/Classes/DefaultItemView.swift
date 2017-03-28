import Cocoa

open class DefaultItemView: View, ItemConfigurable, ViewStateDelegate {

  open override var isFlipped: Bool { return true }

  open var preferredViewSize = Configuration.defaultViewSize

  lazy var titleLabel: NSTextField = {
    let label = NSTextField()
    label.isEditable = false
    label.isSelectable = false
    label.isBezeled = false
    label.drawsBackground = false

    return label
  }()

  lazy var subtitleLabel: NSTextField = {
    let label = NSTextField()
    label.isEditable = false
    label.isSelectable = false
    label.isBezeled = false
    label.textColor = NSColor.black.withAlphaComponent(0.9)
    label.drawsBackground = false

    return label
  }()

  lazy var textLabel: NSTextField = {
    let label = NSTextField()
    label.isEditable = false
    label.isSelectable = false
    label.isBezeled = false
    label.textColor = NSColor.black.withAlphaComponent(0.9)
    label.drawsBackground = false

    return label
  }()

  lazy var lineView: NSView = {
    let view = NSView()
    view.frame.size.height = 1
    view.wantsLayer = true
    view.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.4).cgColor
    view.autoresizingMask = .viewWidthSizable

    return view
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
    lineView.translatesAutoresizingMaskIntoConstraints = false

    titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
    titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
    titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true

    subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
    subtitleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
    subtitleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true

    textLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8).isActive = true
    textLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
    textLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
    textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true

    lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    lineView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    lineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
    lineView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
  }

  open func configure( _ item: inout Item) {
    titleLabel.stringValue = item.title
    subtitleLabel.stringValue = item.subtitle
    textLabel.stringValue = item.text

    var height: CGFloat = 32
    [titleLabel, subtitleLabel, textLabel].forEach {
      let size = $0.sizeThatFits(item.size)
      height += size.height
    }

    item.size.height = height
  }

  public func viewStateDidChange(_ viewState: ViewState) {
    switch viewState {
    case .highlighted:
      layer?.backgroundColor = NSColor.gray.withAlphaComponent(0.3).cgColor
    case .selected:
      layer?.backgroundColor = NSColor.gray.withAlphaComponent(0.3).cgColor
    case .normal:
      layer?.backgroundColor = NSColor.white.cgColor
    }
  }
}
