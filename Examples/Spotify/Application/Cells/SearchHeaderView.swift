import UIKit
import Spots

open class SearchHeaderView: UITableViewHeaderFooterView, Componentable {

  open var preferredHeaderHeight: CGFloat = 88

  lazy var label: UILabel = UILabel(frame: self.frame).then {
    $0.font = UIFont.boldSystemFont(ofSize: 11)
    $0.textColor = UIColor.lightGray
    $0.frame.size.height = 44
  }

  lazy var customBackgroundView: UIView = UIView(frame: self.frame).then {
    $0.backgroundColor = UIColor.darkGray.alpha(0.5)
    $0.height = 44
    $0.y = 44
  }

  open lazy var searchField: UITextField = UITextField(frame: self.frame).then { [unowned self] in
    $0.width -= 30
    $0.height = 44
    $0.y = 44
    $0.x = 15
    $0.font = UIFont.systemFont(ofSize: 18)
    $0.textColor = UIColor.lightGray
    $0.keyboardAppearance = .dark
  }

  lazy var paddedStyle = NSMutableParagraphStyle().then {
    $0.alignment = .left
    $0.firstLineHeadIndent = 15.0
    $0.headIndent = 15.0
    $0.tailIndent = -15.0
  }

  public override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    [customBackgroundView, searchField, label].forEach {
      contentView.addSubview($0)
    }
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open func configure(_ component: Component) {
    backgroundColor = UIColor.clear

    label.attributedText = NSAttributedString(string: component.title.uppercased(),
      attributes: [NSParagraphStyleAttributeName : paddedStyle])
  }
}
