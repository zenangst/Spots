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
}
