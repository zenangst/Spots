import UIKit

extension UICollectionViewCell {

  func optimize() {
    opaque = true
    clipsToBounds = true
  }

  func rasterize() {
    layer.shouldRasterize = true
    layer.rasterizationScale = UIScreen.mainScreen().scale
  }
}
