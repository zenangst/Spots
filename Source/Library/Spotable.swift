import UIKit

public protocol Spotable: class {

  var index: Int { get set }
  weak var sizeDelegate: SpotSizeDelegate? { get set }
  weak var spotDelegate: SpotsDelegate? { get set }
  var component: Component { get set }

  init(component: Component)
  func setup()
  func reload()
  func render() -> UIView
  func layout(size: CGSize)
}
