import UIKit
import Brick

class ListComposite: UITableViewCell, SpotComposable {

  override func prepareForReuse() {
    contentView.subviews.forEach { $0.removeFromSuperview() }
  }
}
