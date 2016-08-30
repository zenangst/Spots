import UIKit
import Brick

class CarouselComposite: UICollectionViewCell, SpotComposable {

  override func prepareForReuse() {
    contentView.subviews.forEach { $0.removeFromSuperview() }
  }
}
