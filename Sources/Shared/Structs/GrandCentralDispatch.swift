import Foundation

public enum SpotDispatchQueue {
  case Main, Interactive, Initiated, Utility, Background, Custom(dispatch_queue_t)
}


struct Dispatch {

  private static func queue(withType queueType: SpotDispatchQueue = .Main) -> dispatch_queue_t {
    let queue: dispatch_queue_t

    switch queueType {
    case .Main:
      queue = dispatch_get_main_queue()
    case .Interactive:
      queue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
    case .Initiated:
      queue = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
    case .Utility:
      queue = dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)
    case .Background:
      queue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
    case .Custom(let userQueue):
      queue = userQueue
    }

    return queue
  }


  static func mainQueue(closure: () -> Void) {
    inQueue(queue: .Main, closure: closure)
  }

  static func inQueue(queue queueType: SpotDispatchQueue = .Main, closure: () -> Void) {
    dispatch_async(Dispatch.queue(withType: queueType), {
      closure()
    })
  }

  static func delay(`for` delay: Double, queue queueType: SpotDispatchQueue = .Main, closure: () -> Void) {
    dispatch_after(
      dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))),
      Dispatch.queue(withType: queueType),
      closure
    )
  }
}
