import UIKit
import Spots
import Sugar

open class ListHeaderView: UITableViewHeaderFooterView, Componentable {

  open var preferredHeaderHeight: CGFloat = 44

  lazy var paddedStyle: NSParagraphStyle = NSMutableParagraphStyle().then {
    $0.alignment = .left
    $0.firstLineHeadIndent = 15.0
    $0.headIndent = 15.0
    $0.tailIndent = -15.0
  }

  public override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    contentView.backgroundColor = UIColor.black
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open func configure(_ component: Component) {
    textLabel?.textColor = UIColor.gray
  }

  open override func layoutSubviews() {
    super.layoutSubviews()

    textLabel?.font = UIFont.boldSystemFont(ofSize: 11)
    textLabel?.text = textLabel?.text?.uppercased()
  }
}
