import UIKit
import Spots

open class ListHeaderView: UITableViewHeaderFooterView, Componentable {

  open var preferredHeaderHeight: CGFloat = 44

  lazy var label: UILabel = { [unowned self] in
    let label = UILabel(frame: self.frame)
    label.font = UIFont.boldSystemFont(ofSize: 11)

    return label
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
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open func configure(_ component: Component) {
    backgroundColor = UIColor.white

    label.attributedText = NSAttributedString(string: component.title.uppercased(),
      attributes: [NSParagraphStyleAttributeName : paddedStyle])
  }
}
