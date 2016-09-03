import Brick
import Foundation

public typealias ViewModelChanges = (
  insertions: [Int],
  updates: [Int],
  reloads: [Int],
  deletions: [Int],
  updatedChildren: [Int]
)

public enum ViewModelDiff {
  case Identifier, Index, Title, Subtitle, Image, Kind, Action, Meta, Children, Relations, Size, New, Removed, None
}

public extension ViewModel {

  static func evaluate(newModels: [ViewModel], oldModels: [ViewModel]) -> [ViewModelDiff]? {
    let newChildren = newModels.flatMap { $0.children }
    let oldChildren = oldModels.flatMap { $0.children }

    guard !(oldModels == newModels) || !(newChildren as NSArray).isEqualToArray(oldChildren) else {
      return nil
    }

    var changes = [ViewModelDiff]()

    if oldModels.count > newModels.count {
      for (index, element) in oldModels.enumerate() {
        if index > newModels.count - 1 {
          changes.append(.Removed)
          continue
        }

        changes.append(element.diff(newModels[index]))
      }
    } else if oldModels.count < newModels.count {
      for (index, element) in newModels.enumerate() {
        if index > oldModels.count - 1 {
          changes.append(.New)
          continue
        }

        changes.append(element.diff(oldModels[index]))
      }
    } else {
      for (index, element) in newModels.enumerate() {
        changes.append(element.diff(oldModels[index]))
      }
    }

    return changes
  }

  public static func processChanges(changes: [ViewModelDiff]) -> (ViewModelChanges) {
    var insertions = [Int]()
    var updates = [Int]()
    var reloads = [Int]()
    var deletions = [Int]()
    var childrenUpdates = [Int]()

    for (index, change) in changes.enumerate() {
      switch change {
      case .Kind, .Size:
        reloads.append(index)
      case .Children:
        childrenUpdates.append(index)
      case .New:
        insertions.append(index)
      case .Removed:
        deletions.append(index)
      case .None: break
      default:
        updates.append(index)
      }
    }

    return (insertions: insertions, updates: updates, reloads: reloads, deletions: deletions, updatedChildren: childrenUpdates)
  }

  public func diff(oldViewModel: ViewModel) -> ViewModelDiff {

    let newChildren = children.map { Component($0) }
    let oldChildren = oldViewModel.children.map { Component($0) }

    if kind != oldViewModel.kind { return .Kind }
    if newChildren != oldChildren { return .Children }
    if identifier != oldViewModel.identifier { return .Identifier }
    if title != oldViewModel.title { return .Title }
    if subtitle != oldViewModel.subtitle { return .Subtitle }
    if image != oldViewModel.image { return .Image }
    if action != oldViewModel.action { return .Action }
    if !(meta as NSDictionary).isEqualToDictionary(oldViewModel.meta) { return .Meta }

    return .None
  }

}
