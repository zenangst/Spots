import UIKit
import Spots

public class SearchHeaderView: UIView, Componentable {

  public var defaultHeight: CGFloat = 88

  lazy var label: UILabel = UILabel(frame: self.frame).then {
    $0.font = UIFont.boldSystemFontOfSize(11)
    $0.textColor = UIColor.lightGrayColor()
  }

  lazy var backgroundView: UIView = UIView(frame: self.frame).then {
    $0.backgroundColor = UIColor.darkGrayColor().alpha(0.5)
    $0.height = 44
    $0.y = 44
  }

  public lazy var searchField: UITextField = UITextField(frame: self.frame).then { [unowned self] in
    $0.width -= 30
    $0.height = 44
    $0.y = 44
    $0.x = 15
    $0.font = UIFont.systemFontOfSize(18)
    $0.textColor = UIColor.lightGrayColor()
    $0.keyboardAppearance = .Dark
  }

  lazy var paddedStyle = NSMutableParagraphStyle().then {
    $0.alignment = .Left
    $0.firstLineHeadIndent = 15.0
    $0.headIndent = 15.0
    $0.tailIndent = -15.0
  }

  public override init(frame: CGRect) {
    super.init(frame: frame)
    [backgroundView, searchField, label].forEach { addSubview($0) }
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func configure(component: Component) {
    backgroundColor = UIColor.clearColor()

    label.attributedText = NSAttributedString(string: component.title.uppercaseString,
      attributes: [NSParagraphStyleAttributeName : paddedStyle])
  }
}
