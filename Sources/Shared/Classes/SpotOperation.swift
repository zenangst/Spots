import Foundation

final class SpotOperation: ConcurrentOperation {

  typealias Task = () -> Void
  fileprivate var task: Task?

  // MARK: - Initialization

  init(task: @escaping Task) {
    self.task = task
  }

  deinit {
    task = nil
  }

  // MARK: - Operation

  override func execute() {
    task?()
    state = .Finished
  }

  override func cancel() {
    super.cancel()
    task = nil
  }
}
