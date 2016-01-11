#if os(iOS)
  import UIKit
#else
  import Foundation
#endif

public protocol Componentable {
  var height: CGFloat { get }
  func configure(component: Component)
}
