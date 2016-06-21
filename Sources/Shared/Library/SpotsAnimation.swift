#if os(iOS)
  import UIKit
#else
  import Cocoa
#endif

/**
 The type of animation when items are inserted or deleted.
 */
public enum SpotsAnimation: Int {
  case Fade
  case Right
  case Left
  case Top
  case Bottom
  case None
  case Middle
  case Automatic

  #if os(iOS)
  /**
   Resolves a SpotsAnimation into a UITableViewRowAnimation
   */
  var tableViewAnimation: UITableViewRowAnimation {
    switch self {
    case .Fade:
      return UITableViewRowAnimation.Fade
    case .Right:
      return UITableViewRowAnimation.Right
    case .Left:
      return UITableViewRowAnimation.Left
    case .Top:
      return UITableViewRowAnimation.Top
    case .Bottom:
      return UITableViewRowAnimation.Bottom
    case .None:
      return UITableViewRowAnimation.None
    case .Middle:
      return UITableViewRowAnimation.Middle
    case .Automatic:
      return UITableViewRowAnimation.Automatic
    }
  }
  #else
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
  #endif
}
