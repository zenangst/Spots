import UIKit
import Brick

class ListComposite: UITableViewCell, SpotComposite {

  override func prepareForReuse() {
    contentView.subviews.forEach { $0.removeFromSuperview() }
  }
}
