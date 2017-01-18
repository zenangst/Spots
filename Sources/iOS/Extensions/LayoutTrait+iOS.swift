import UIKit

extension LayoutTrait {

  public func configure(spot: Gridable) {
    sectionInset.configure(layout: spot.layout)
    contentInset.configure(scrollView: spot.render())
  }

  public func configure(spot: Listable) {
    contentInset.configure(scrollView: spot.render())
  }
}
