import UIKit

protocol Spotable: class {
  weak var sizeDelegate: SpotSizeDelegate? { get set }
  var component: Component { get set }

  func render() -> UIView
  func layout(size: CGSize)
}

extension Spotable {
  func layout(size: CGSize) { }
}
