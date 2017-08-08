struct Changes {

  var insertions: Set<Int> = []
  var updates: Set<Int> = []
  var reloads: Set<Int> = []
  var deletions: Set<Int> = []
  var childUpdates: Set<Int> = []
  var moved: [Int: Int] = [:]

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
