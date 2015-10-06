import UIKit

protocol ComponentContainer: class {
  weak var sizeDelegate: ComponentSizeDelegate? { get set }
  var component: Component { get set }

  func render() -> UIView
}
