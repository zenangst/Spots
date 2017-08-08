/// `Changes` is the result value of the `DiffManager` when comparing two collection of
/// items. It contains insertions, updates, reload, deletions, child updates and move instructions.
/// It is used in methods like `reloadIfNeeded` on controller and component level.
public struct Changes {
  /// A collection of indexes that should be inserted.
  var insertions: Set<Int> = []
  /// A collection of indexes that should update.
  var updates: Set<Int> = []
  /// A collection of indexes that should reload.
  var reloads: Set<Int> = []
  /// A collection of indexes that should be deleted.
  var deletions: Set<Int> = []
  /// A collection of indexes that represent child updates, this is used for when a composite
  /// component is updated inside of an item.
  var childUpdates: Set<Int> = []
  /// A dictionary of indexes, the key represents the initial location and the value is the new
  /// index of the item after the update.
  var moved: [Int: Int] = [:]

  /// Initialize a new `Changes` object with a collection of `ItemDiff`s.
  /// This is usually generated inside `DiffManager`.
  ///
  /// - Parameter itemDiffs: A collection of `ItemDiff`s.
  init(itemDiffs: [ItemDiff]) {
    for (index, itemDiff) in itemDiffs.enumerated() {
      switch itemDiff {
      case .kind, .size:
        reloads.insert(index)
      case .children:
        childUpdates.insert(index)
      case .new:
        insertions.insert(index)
      case .removed:
        deletions.insert(index)
      case .move(let from, let to):
        moved[from] = to
      case .none: break
      default:
        updates.insert(index)
      }
    }
  }
}
