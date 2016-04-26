#if os(iOS)
  import UIKit
#else
  import Foundation
#endif

public protocol Componentable {
  var defaultHeight: CGFloat { get }
  func configure(component: Component)
}
