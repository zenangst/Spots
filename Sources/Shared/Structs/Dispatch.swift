import Foundation

/// A static struct to scope dispatch commands
public struct Dispatch {

  /// Dispatch in the main queue.
  ///
  /// - Parameter closure: The closure that should be dispatched.
  static func main(closure: @escaping () -> Void) {
    DispatchQueue.main.async {
      closure()
    }
  }

  /// Dispatch in an interactive queue.
  ///
  /// - Parameter closure: The closure that should be dispatched.
  static func interactive(closure: @escaping () -> Void) {
    DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async {
      closure()
    }
  }

  /// Delay executation of operation in queue.
  ///
  /// - parameter delay:     The delay that should be used, in seconds.
  /// - parameter queueType: The queue that should be used for dispatching the operation.
  /// - parameter closure:   The closure that should be dispatched.
  static func after(seconds delay: Double, queue: DispatchQueue = .main, closure: @escaping () -> Void) {
    queue.asyncAfter(
      deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
      execute: closure
    )
  }
}
