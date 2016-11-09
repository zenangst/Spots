import Foundation

final class SpotOperation: ConcurrentOperation {

  typealias Task = (@escaping () -> Void) -> Void
  fileprivate var completion: Completion
  fileprivate var task: Task?

  // MARK: - Initialization

  init(_ completion: Completion, task: @escaping Task) {
    self.completion = completion
    self.task = task
  }

  deinit {
    task = nil
    completion = nil
  }

  // MARK: - Operation

  override func execute() {
    task? { [weak self] in
      self?.state = .Finished
      self?.completion?()
    }
  }

  override func cancel() {
    super.cancel()
    task = nil
    completion = nil
  }
}
