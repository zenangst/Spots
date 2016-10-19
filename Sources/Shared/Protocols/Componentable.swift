#if os(iOS)
  import UIKit
#else
  import Foundation
#endif

/// A protocol for Componentable objects.
public protocol Componentable {
  /// The preferred header height for the Componentable object.
  var preferredHeaderHeight: CGFloat { get }

  /// A structure that contains the location and dimensions of a rectangle.
  var frame: CGRect { get }

  /// Configure object with Component struct.
  ///
  /// - parameter component: The component that should be used for configuration.
  func configure(_ component: Component)
}
