import Foundation

/// A dispatch enum
///
/// - main:        DispatchQueue.main
/// - interactive: DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive)
/// - initiated:   DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)
/// - utility:     DispatchQueue.global(qos: DispatchQoS.QoSClass.utility)
/// - background:  DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
/// - custom:      A user defined queue
public enum SpotDispatchQueue {
  case main, interactive, initiated, utility, background, custom(DispatchQueue)
}

/// A static struct to scope dispatch commands
struct Dispatch {

  /// Determines which queue should be used for dispatching
  ///
  /// - parameter queueType: The queue type that should be used, see `SpotDispatchQueue`
  ///
  /// - returns: A DispatchQueue, resolved based on `queueType`
  fileprivate static func queue(withType queueType: SpotDispatchQueue = .main) -> DispatchQueue {
    let queue: DispatchQueue

    switch queueType {
    case .main:
      queue = DispatchQueue.main
    case .interactive:
      queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive)
    case .initiated:
      queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)
    case .utility:
      queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.utility)
    case .background:
      queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
    case .custom(let userQueue):
      queue = userQueue
    }

    return queue
  }

  /// Dispatch closure in main queue.
  ///
  /// - parameter closure: The closure that should run in the main queue.
  static func mainQueue(_ closure: @escaping () -> Void) {
    inQueue(queue: .main, closure: closure)
  }

  /// Dispatch closure in queue based of `queueType`
  ///
  /// - parameter queueType: The queue that should be used for dispatching the operation.
  /// - parameter closure:   The closure that should be dispatched.
  static func inQueue(queue queueType: SpotDispatchQueue = .main, closure: @escaping () -> Void) {
    Dispatch.queue(withType: queueType).async(execute: {
      closure()
    })
  }

  /// Delay executation of operation in queue.
  ///
  /// - parameter delay:     The delay that should be used, in seconds.
  /// - parameter queueType: The queue that should be used for dispatching the operation.
  /// - parameter closure:   The closure that should be dispatched.
  static func delay(for delay: Double, queue queueType: SpotDispatchQueue = .main, closure: @escaping () -> Void) {
    Dispatch.queue(withType: queueType).asyncAfter(
      deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
      execute: closure
    )
  }
}
