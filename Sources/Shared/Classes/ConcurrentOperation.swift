import Foundation

class ConcurrentOperation: Operation {

  enum State: String {
    case Ready = "isReady"
    case Executing = "isExecuting"
    case Finished = "isFinished"
  }

  var state = State.Ready {
    willSet {
      willChangeValue(forKey: newValue.rawValue)
      willChangeValue(forKey: state.rawValue)
    }
    didSet {
      didChangeValue(forKey: oldValue.rawValue)
      didChangeValue(forKey: state.rawValue)
    }
  }

  override var isAsynchronous: Bool {
    return true
  }

  override var isReady: Bool {
    return super.isReady && state == .Ready
  }

  override var isExecuting: Bool {
    return state == .Executing
  }

  override var isFinished: Bool {
    return state == .Finished
  }

  override func start() {
    guard !isCancelled else {
      state = .Finished
      return
    }

    execute()
  }

  func execute() {
    state = .Executing
  }
}
