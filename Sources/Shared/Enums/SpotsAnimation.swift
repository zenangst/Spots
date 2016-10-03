#if os(iOS)
  import UIKit
#endif
#if os(tvOS)
  import UIKit
#endif
#if os(OSX)
  import Cocoa
#endif

/**
 The type of animation when items are inserted or deleted.
 */
public enum SpotsAnimation: Int {
  case fade
  case right
  case left
  case top
  case bottom
  case none
  case middle
  case automatic

  #if os(OSX)
  var tableViewAnimation: NSTableViewAnimationOptions {
    switch self {
    case .fade:
      return NSTableViewAnimationOptions.effectFade
    case .right:
      return NSTableViewAnimationOptions.slideRight
    case .left:
      return NSTableViewAnimationOptions.slideLeft
    case .top:
      return NSTableViewAnimationOptions.slideUp
    case .bottom:
      return NSTableViewAnimationOptions.slideDown
    case .none:
      return NSTableViewAnimationOptions()
    case .middle:
      return NSTableViewAnimationOptions.effectGap
    case .automatic:
      return NSTableViewAnimationOptions.effectFade
    }
  }
  #else
  /**
   Resolves a SpotsAnimation into a UITableViewRowAnimation
   */
  var tableViewAnimation: UITableViewRowAnimation {
    switch self {
    case .fade:
      return UITableViewRowAnimation.fade
    case .right:
      return UITableViewRowAnimation.right
    case .left:
      return UITableViewRowAnimation.left
    case .top:
      return UITableViewRowAnimation.top
    case .bottom:
      return UITableViewRowAnimation.bottom
    case .none:
      return UITableViewRowAnimation.none
    case .middle:
      return UITableViewRowAnimation.middle
    case .automatic:
      return UITableViewRowAnimation.automatic
    }
  }
  #endif
}
