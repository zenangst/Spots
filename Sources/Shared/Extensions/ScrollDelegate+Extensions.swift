/// A dummy scroll delegate extension to make didReachBeginning optional
public extension ScrollDelegate {

  /// A default implementation for didReachBeginning, it renders the method optional
  ///
  /// - parameter completion: A completion closure
  func didReachBeginning(in scrollView: ScrollableView, completion: Completion) {
    completion?()
  }
}
