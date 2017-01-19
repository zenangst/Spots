import UIKit

extension Layout {

  public func configure(spot: Gridable) {
    sectionInset.configure(layout: spot.layout)
    contentInset.configure(scrollView: spot.render())

    spot.layout.minimumInteritemSpacing = CGFloat(itemSpacing)
    spot.layout.minimumLineSpacing = CGFloat(lineSpacing)
  }
}
