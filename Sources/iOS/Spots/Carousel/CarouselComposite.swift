import UIKit
import Brick

class CarouselComposite: UICollectionViewCell, SpotComposite {

  override func prepareForReuse() {
    contentView.subviews.forEach { $0.removeFromSuperview() }
  }
}
