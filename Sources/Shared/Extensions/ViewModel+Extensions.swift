import Brick
import Foundation

public typealias ItemChanges = (
  insertions: [Int],
  updates: [Int],
  reloads: [Int],
  deletions: [Int],
  updatedChildren: [Int]
)

public enum ItemDiff {
  case identifier, index, title, subtitle, image, kind, action, meta, children, relations, size, new, removed, none
}

public extension Item {

  static func evaluate(_ newModels: [Item], oldModels: [Item]) -> [ItemDiff]? {
    let newChildren = newModels.flatMap { $0.children }
    let oldChildren = oldModels.flatMap { $0.children }

    guard !(oldModels == newModels) || !(newChildren as NSArray).isEqual(to: oldChildren) else {
      return nil
    }

    var changes = [ItemDiff]()

    if oldModels.count > newModels.count {
      for (index, element) in oldModels.enumerated() {
        if index > newModels.count - 1 {
          changes.append(.Removed)
          continue
        }

        changes.append(element.diff(newModels[index]))
      }
    } else if oldModels.count < newModels.count {
      for (index, element) in newModels.enumerated() {
        if index > oldModels.count - 1 {
          changes.append(.New)
          continue
        }

        changes.append(element.diff(oldModels[index]))
      }
    } else {
      for (index, element) in newModels.enumerated() {
        changes.append(element.diff(oldModels[index]))
      }
    }

    return changes
  }

  /**
   Process a collection of item diffs

   - parameter changes: A collection of `ItemDiff`s

   - returns: A tuple containg reloads, child updates, insertions, deletions and reload indexes
   */
  public static func processChanges(_ changes: [ItemDiff]) -> (ItemChanges) {
    var insertions = [Int]()
    var updates = [Int]()
    var reloads = [Int]()
    var deletions = [Int]()
    var childrenUpdates = [Int]()

    for (index, change) in changes.enumerated() {
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

  /**
   Diff current item with previous item

   - parameter oldItem: The previous item that you want to compare the new one towards

   - returns: An `ItemDiff` enum key
   */
  public func diff(_ oldItem: Item) -> ItemDiff {

    let newChildren = children.map { Component($0 as [String : AnyObject]) }
    let oldChildren = oldItem.children.map { Component($0 as [String : AnyObject]) }

    if kind != oldItem.kind { return .Kind }
    if newChildren != oldChildren { return .Children }
    if identifier != oldItem.identifier { return .Identifier }
    if title != oldItem.title { return .Title }
    if subtitle != oldItem.subtitle { return .Subtitle }
    if image != oldItem.image { return .Image }
    if action != oldItem.action { return .Action }
    if !(meta as NSDictionary).isEqual(to: oldItem.meta) { return .Meta }

    return .None
  }

}
