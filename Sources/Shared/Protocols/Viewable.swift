#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif

/// Viewable is a protocol for Spots that are based on UIScrollView
public protocol Viewable: Spotable {
  /// A view registry that is used internally when resolving kind to the corresponding spot.
  static var views: Registry { get }
  /// A ScrollView
  var scrollView: ScrollView { get }
}
