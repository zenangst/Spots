#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif

import Sugar
import Brick

/// Viewable is a protocol for Spots that are based on UIScrollView
public protocol Viewable: Spotable {
  /// A view registry that is used internally when resolving kind to the corresponding spot.
  static var views: Registry { get }
  /// The default view type for the spotable object
  static var defaultView: View.Type { get set }

  /// The default kind to fall back to if the view model kind does not exist when trying to display the spotable item
  static var defaultKind: StringConvertible { get }

  var scrollView: ScrollView { get }
}
