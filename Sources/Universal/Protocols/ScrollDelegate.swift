import CoreGraphics

/// A scroll delegate for handling didReachBeginning and didReachEnd
public protocol ScrollDelegate: class {

  /// A delegate method that is triggered when the scroll view reaches the top
  ///
  /// - parameter completion: A completion closure that gets triggered when the view did reach the beginning of the scroll view.
  func didReachBeginning(in scrollView: ScrollableView, completion: Completion)

  /// A delegate method that is triggered when the scroll view reaches the end
  ///
  /// - parameter completion: A completion closure that gets triggered when the view did reach the end of the scroll view.
  func didReachEnd(in scrollView: ScrollableView, completion: Completion)

  #if os(tvOS)
  /// A delegate method that notifies when the `SpotsScrollView` scrolls. It has a return value
  /// that can be used to opt out from the default implementation of standard `SpotsScrollView` behavior.
  /// If the method is `true`, then `didReachBeginning` and `didReachEnd` will not be invoked.
  ///
  /// - Parameter scrollView: The scroll view that user interacted with.
  /// - Returns: Return `true` if you want to override the default implementation.
  func didScroll(in scrollView: ScrollView) -> Bool

  /// A delegate method that is invoked when the user stops interacting with the scroll view.
  /// This can be used to tailor the scroll view position depending on the content.
  /// If the method returns `true`, it will opt-out of doing any default scroll view position
  /// handling.
  ///
  /// - Parameters:
  ///   - scrollView: The scroll view that user interacted with.
  ///   - velocity: The velocity of the scroll gesture.
  ///   - targetContentOffset: The `targetContentOffset` is the end position for the scroll operation,
  ///                          you can modify the `.pointee` value to get fine-grained control over
  ///                          where the scrolling should end up.
  /// - Returns: Return `true` if you want to override the default implementation.
  func didEndDragging(in scrollView: ScrollableView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) -> Bool
  #endif
}
