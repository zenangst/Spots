import UIKit

public protocol Spotable: class {
  weak var sizeDelegate: SpotSizeDelegate? { get set }
  var component: Component { get set }

  init(component: Component)
  func render() -> UIView
  func layout(size: CGSize)
}
