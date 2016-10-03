import Foundation

/**
 A dispatch enum

 - Main:        dispatch_get_main_queue
 - Interactive: dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
 - Initiated:   dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
 - Utility:     dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)
 - Background:  dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
 - Custom:      A user defined queue
 */
public enum SpotDispatchQueue {
  case main, interactive, initiated, utility, background, custom(DispatchQueue)
}

struct Dispatch {

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

  static func mainQueue(_ closure: @escaping () -> Void) {
    inQueue(queue: .main, closure: closure)
  }

  static func inQueue(queue queueType: SpotDispatchQueue = .main, closure: @escaping () -> Void) {
    Dispatch.queue(withType: queueType).async(execute: {
      closure()
    })
  }

  static func delay(for delay: Double, queue queueType: SpotDispatchQueue = .main, closure: @escaping () -> Void) {
    Dispatch.queue(withType: queueType).asyncAfter(
      deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
      execute: closure
    )
  }
}
