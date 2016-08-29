import UIKit
import Brick

class GridComposite: UICollectionViewCell, SpotComposite {

  override func prepareForReuse() {
    contentView.subviews.forEach { $0.removeFromSuperview() }
  }
}
