import UIKit
import Brick

class GridComposite: UICollectionViewCell, SpotComposable {

  override func prepareForReuse() {
    contentView.subviews.forEach { $0.removeFromSuperview() }
  }
}
