import Cocoa
import Spots

class HeaderView: NSView, ItemConfigurable {

  lazy var titleLabel: NSTextField = {
    let label = NSTextField()
    return label
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(titleLabel)

    wantsLayer = true
    layer?.backgroundColor = NSColor.gray.withAlphaComponent(0.25).cgColor

    configureConstraints()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configureConstraints() {
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
    titleLabel.leftAnchor.constraint(equalTo: titleLabel.superview!.leftAnchor).isActive = true
    titleLabel.rightAnchor.constraint(equalTo: titleLabel.superview!.rightAnchor).isActive = true
    titleLabel.centerYAnchor.constraint(equalTo: titleLabel.superview!.centerYAnchor).isActive = true
  }

  func computeSize(for item: Item, containerSize: CGSize) -> CGSize {
    return CGSize(width: 200, height: 50)
  }

  func configure(with item: Item) {
    titleLabel.stringValue = item.title
  }
}

class TextView: NSView, ItemConfigurable {

  lazy var titleLabel: NSTextField = {
    let label = NSTextField()
    return label
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(titleLabel)

    wantsLayer = true
    layer?.backgroundColor = NSColor.gray.withAlphaComponent(0.25).cgColor

    configureConstraints()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configureConstraints() {
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
    titleLabel.leftAnchor.constraint(equalTo: titleLabel.superview!.leftAnchor).isActive = true
    titleLabel.rightAnchor.constraint(equalTo: titleLabel.superview!.rightAnchor).isActive = true
    titleLabel.centerYAnchor.constraint(equalTo: titleLabel.superview!.centerYAnchor).isActive = true
  }

  func configure(with item: Item) {
    titleLabel.stringValue = item.title
  }

  func computeSize(for item: Item, containerSize: CGSize) -> CGSize {
    return CGSize(width: 200, height: 50)
  }
}

class FooterView: NSView, ItemConfigurable {

  lazy var titleLabel: NSTextField = {
    let label = NSTextField()
    return label
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(titleLabel)

    wantsLayer = true
    layer?.backgroundColor = NSColor.gray.withAlphaComponent(0.25).cgColor

    configureConstraints()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configureConstraints() {
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
    titleLabel.leftAnchor.constraint(equalTo: titleLabel.superview!.leftAnchor).isActive = true
    titleLabel.rightAnchor.constraint(equalTo: titleLabel.superview!.rightAnchor).isActive = true
    titleLabel.centerYAnchor.constraint(equalTo: titleLabel.superview!.centerYAnchor).isActive = true
  }

  func configure(with item: Item) {
    titleLabel.stringValue = item.title
  }

  func computeSize(for item: Item, containerSize: CGSize) -> CGSize {
    return CGSize(width: 200, height: 50)
  }

}
