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
    case .Fade:
      return NSTableViewAnimationOptions.EffectFade
    case .Right:
      return NSTableViewAnimationOptions.SlideRight
    case .Left:
      return NSTableViewAnimationOptions.SlideLeft
    case .Top:
      return NSTableViewAnimationOptions.SlideUp
    case .Bottom:
      return NSTableViewAnimationOptions.SlideDown
    case .None:
      return NSTableViewAnimationOptions.EffectNone
    case .Middle:
      return NSTableViewAnimationOptions.EffectGap
    case .Automatic:
      return NSTableViewAnimationOptions.EffectFade
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
