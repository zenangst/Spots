import UIKit
import Spots

public class SearchHeaderView: UIView, Componentable {

  public var defaultHeight: CGFloat = 88

  lazy var label: UILabel = { [unowned self] in
    let label = UILabel(frame: self.frame)
    label.font = UIFont.boldSystemFontOfSize(11)

    return label
    }()

  lazy var backgroundView: UIView = {
    let view = UITextField(frame: self.frame)
    view.backgroundColor = UIColor(red:0.961, green:0.961, blue:0.961, alpha: 1)
    view.height = 44
    view.y = 44

    return view
    }()

  public lazy var searchField: UITextField = { [unowned self] in
    let searchField = UITextField(frame: self.frame)
    searchField.width -= 30
    searchField.height = 44
    searchField.y = 44
    searchField.x = 15
    searchField.font = UIFont.systemFontOfSize(18)

    return searchField
    }()

  lazy var paddedStyle: NSParagraphStyle = {
    let style = NSMutableParagraphStyle()
    style.alignment = .Left
    style.firstLineHeadIndent = 15.0
    style.headIndent = 15.0
    style.tailIndent = -15.0

    return style
    }()

  public override init(frame: CGRect) {
    super.init(frame: frame)
    [backgroundView, searchField, label].forEach { addSubview($0) }
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func configure(component: Component) {
    backgroundColor = UIColor.whiteColor()

    label.attributedText = NSAttributedString(string: component.title.uppercaseString,
      attributes: [NSParagraphStyleAttributeName : paddedStyle])
  }
}
