import UIKit
import Spots
import Sugar

public class ListHeaderView: UIView, Componentable {

  public var defaultHeight: CGFloat = 44

  lazy var label: UILabel = UILabel().then { [unowned self] in
    $0.frame = self.frame
    $0.font = UIFont.boldSystemFontOfSize(11)
  }

  lazy var paddedStyle: NSParagraphStyle = NSMutableParagraphStyle().then {
    $0.alignment = .Left
    $0.firstLineHeadIndent = 15.0
    $0.headIndent = 15.0
    $0.tailIndent = -15.0
  }

  public override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(label)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func configure(component: Component) {
    label.textColor = UIColor.grayColor()
    label.attributedText = NSAttributedString(string: component.title.uppercaseString,
      attributes: [NSParagraphStyleAttributeName : paddedStyle])
    label.height = component.meta("headerHeight", 0.0)
  }
}
