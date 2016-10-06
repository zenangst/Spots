#if os(iOS)
  import UIKit
#else
  import Foundation
#endif

public protocol Componentable {
  var preferredHeaderHeight: CGFloat { get }
  func configure(_ component: Component)
}
