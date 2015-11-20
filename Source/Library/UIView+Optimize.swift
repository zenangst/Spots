import UIKit

extension UIView {

  func optimize() {
    opaque = true
    clipsToBounds = true
    layer.drawsAsynchronously = true
    backgroundColor = UIColor.whiteColor()
  }
}
