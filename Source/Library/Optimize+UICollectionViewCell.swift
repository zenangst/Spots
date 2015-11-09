import UIKit

extension UICollectionViewCell {

  func optimize() {
    opaque = true
    clipsToBounds = true
  }

  func rasterize() {
    layer.drawsAsynchronously = true
    layer.shouldRasterize = true
    layer.rasterizationScale = UIScreen.mainScreen().scale
  }
}
