import UIKit

extension UIView {

  func optimize() {
    opaque = true
    clipsToBounds = true
    layer.drawsAsynchronously = true
  }

  func rasterize() {
    layer.shouldRasterize = true
    layer.rasterizationScale = UIScreen.mainScreen().scale
  }
}
