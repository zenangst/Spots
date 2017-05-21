import UIKit

class ComponentCollectionView: UICollectionView {

  var component: Component?

  override func layoutSubviews() {
    super.layoutSubviews()
    component?.layoutSubviews()
  }
}
