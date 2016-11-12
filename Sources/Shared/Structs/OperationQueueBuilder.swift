import Foundation

struct OperationQueueBuilder {

  static func build() -> OperationQueue {
    let operationQueue = OperationQueue()
    operationQueue.maxConcurrentOperationCount = 1
    operationQueue.qualityOfService = .userInitiated
    return operationQueue
  }
}
