import UIKit

extension Layout {

  public func configure(spot: Gridable) {
    inset.configure(layout: spot.layout)
    inset.configure(scrollView: spot.render())

    spot.layout.minimumInteritemSpacing = CGFloat(itemSpacing)
    spot.layout.minimumLineSpacing = CGFloat(lineSpacing)
  }
}
