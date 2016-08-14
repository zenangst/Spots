import UIKit
import Spots
import Sugar

public class ListHeaderView: UITableViewHeaderFooterView, Componentable {

  public var defaultHeight: CGFloat = 44

  lazy var paddedStyle: NSParagraphStyle = NSMutableParagraphStyle().then {
    $0.alignment = .Left
    $0.firstLineHeadIndent = 15.0
    $0.headIndent = 15.0
    $0.tailIndent = -15.0
  }

  public override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    contentView.backgroundColor = UIColor.blackColor()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func configure(component: Component) {
    textLabel?.textColor = UIColor.grayColor()
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    textLabel?.font = UIFont.boldSystemFontOfSize(11)
    textLabel?.text = textLabel?.text?.uppercaseString
  }
}
