import UIKit
import Spots
import Brick

class CompositionListHeader: UITableViewHeaderFooterView, Componentable {

  var preferredHeaderHeight: CGFloat = 120

  lazy var label = UILabel()

  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    addSubview(label)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(_ component: Component) {
    label.text = component.title
    label.frame.size.width = frame.width - 20
    label.frame.size.height = preferredHeaderHeight
    label.frame.origin.x = 10
    label.frame.origin.y = preferredHeaderHeight / 2 - label.frame.size.height / 2
  }
}
