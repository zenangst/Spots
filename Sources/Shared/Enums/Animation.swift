#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif

///
/// The type of animation when items are inserted or deleted.
///
public enum Animation: Int {
  case fade
  case right
  case left
  case top
  case bottom
  case none
  case middle
  case automatic

  #if os(OSX)
  ///
  /// Resolves a Animation into a NSTableViewAnimationOptions
  ///
  public var tableViewAnimation: NSTableViewAnimationOptions {
    switch self {
    case .fade:
      return .effectFade
    case .right:
      return .slideRight
    case .left:
      return .slideLeft
    case .top:
      return .slideUp
    case .bottom:
      return .slideDown
    case .none:
      return NSTableViewAnimationOptions()
    case .middle:
      return .effectGap
    case .automatic:
      return .effectFade
    }
  }
  #else
  ///
  /// Resolves a Animation into a UITableViewRowAnimation
  ///
  public var tableViewAnimation: UITableViewRowAnimation {
    switch self {
    case .fade:
      return .fade
    case .right:
      return .right
    case .left:
      return .left
    case .top:
      return .top
    case .bottom:
      return .bottom
    case .none:
      return .none
    case .middle:
      return .middle
    case .automatic:
      return .automatic
    }
  }
  #endif
}
