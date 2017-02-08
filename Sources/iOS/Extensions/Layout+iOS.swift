import UIKit

extension Layout {

  public func configure(spot: Gridable) {
    inset.configure(scrollView: spot.view)

    spot.layout.minimumInteritemSpacing = CGFloat(itemSpacing)
    spot.layout.minimumLineSpacing = CGFloat(lineSpacing)
  }

  public func configure(spot: Spot) {
    inset.configure(scrollView: spot.view)
  }

  public func configure(collectionViewLayout: UICollectionViewLayout?) {
    if let flowLayout = collectionViewLayout as? FlowLayout {
      flowLayout.minimumInteritemSpacing = CGFloat(itemSpacing)
      flowLayout.minimumLineSpacing = CGFloat(lineSpacing)
    }
  }
}
