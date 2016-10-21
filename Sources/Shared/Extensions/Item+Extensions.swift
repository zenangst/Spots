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
  case identifier, index, title, subtitle, text, image, kind, action, meta, children, relations, size, new, removed, none
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
          changes.append(.removed)
          continue
        }

        changes.append(element.diff(newModels[index]))
      }
    } else if oldModels.count < newModels.count {
      for (index, element) in newModels.enumerated() {
        if index > oldModels.count - 1 {
          changes.append(.new)
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
      case .kind, .size:
        reloads.append(index)
      case .children:
        childrenUpdates.append(index)
      case .new:
        insertions.append(index)
      case .removed:
        deletions.append(index)
      case .none: break
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

    let newChildren = children.map { Component($0 as [String : Any]) }
    let oldChildren = oldItem.children.map { Component($0 as [String : Any]) }

    if kind != oldItem.kind { return .kind }
    if newChildren != oldChildren { return .children }
    if identifier != oldItem.identifier { return .identifier }
    if size != oldItem.size { return .size }
    if title != oldItem.title { return .title }
    if subtitle != oldItem.subtitle { return .subtitle }
    if text != oldItem.text { return .text }
    if image != oldItem.image { return .image }
    if action != oldItem.action { return .action }
    if !(meta as NSDictionary).isEqual(to: oldItem.meta) { return .meta }

    return .none
  }

}
