import UIKit
import Spots
import Sugar

open class SearchHeaderView: UITableViewHeaderFooterView, Componentable {

  open var preferredHeaderHeight: CGFloat = 88

  lazy var label: UILabel = { [unowned self] in
    let label = UILabel(frame: self.bounds)
    label.font = UIFont.boldSystemFont(ofSize: 11)

    return label
    }()

  lazy var customBackgroundView: UIView = {
    let view = UITextField(frame: self.bounds)
    view.backgroundColor = UIColor(red:0.961, green:0.961, blue:0.961, alpha: 1)
    view.height = 44
    view.y = 0

    return view
    }()

  open lazy var searchField: UITextField = { [unowned self] in
    let searchField = UITextField(frame: self.bounds)
    searchField.width -= 30
    searchField.height = 44
    searchField.y = 0
    searchField.x = 15
    searchField.font = UIFont.systemFont(ofSize: 18)

    return searchField
    }()

  lazy var paddedStyle: NSParagraphStyle = {
    let style = NSMutableParagraphStyle()
    style.alignment = .left
    style.firstLineHeadIndent = 15.0
    style.headIndent = 15.0
    style.tailIndent = -15.0

    return style
    }()

  public override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    [customBackgroundView, searchField, label].forEach { addSubview($0) }
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open func configure(_ component: Component) {
    backgroundColor = UIColor.white

    label.attributedText = NSAttributedString(string: component.title.uppercased(),
      attributes: [NSParagraphStyleAttributeName : paddedStyle])

    frame.size.height ?= component.size?.height
  }
}
