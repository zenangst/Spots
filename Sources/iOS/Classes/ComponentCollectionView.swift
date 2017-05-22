import UIKit

class ComponentCollectionView: UICollectionView {

  weak var component: Component?

  override func layoutSubviews() {
    super.layoutSubviews()
    component?.layoutSubviews()
  }
}
