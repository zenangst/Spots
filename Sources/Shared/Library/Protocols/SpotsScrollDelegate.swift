/// A scroll delegate for handling spotDidReachBeginning and spotDidReachEnd
public protocol SpotsScrollDelegate: class {

  /**
   A delegate method that is triggered when the scroll view reaches the top
   */
  func spotDidReachBeginning(completion: Completion)

  /**
   A delegate method that is triggered when the scroll view reaches the end
   */
  func spotDidReachEnd(completion: Completion)
}

/// A dummy scroll delegate extension to make spotDidReachBeginning optional
public extension SpotsScrollDelegate {

  /**
   A default implementation for spotDidReachBeginning, it renders the method optional
   */
  func spotDidReachBeginning(completion: Completion) {
    completion?()
  }
}