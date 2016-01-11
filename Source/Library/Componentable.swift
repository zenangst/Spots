import UIKit

public protocol Componentable {
  var height: CGFloat { get }
  func configure(component: Component)
}
