import UIKit

extension Layout {

  public func configure(spot: Gridable) {
    inset.configure(scrollView: spot.view)

    spot.layout.minimumInteritemSpacing = CGFloat(itemSpacing)
    spot.layout.minimumLineSpacing = CGFloat(lineSpacing)
  }
}
