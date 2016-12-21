extension Listable {

  /**
   Process updates and determine if the updates are done

   - parameter updates:    A collection of updates
   - parameter animation:  A Animation that is used when performing the mutation
   - parameter completion: A completion closure that is run when the updates are finished
   */
  public func process(_ updates: [Int], withAnimation animation: Animation = .automatic, completion: Completion) {
    guard !updates.isEmpty else {
      updateHeight() {
        completion?()
      }
      return
    }

    let lastUpdate = updates.last
    for index in updates {
      guard let item = self.item(at: index) else {
        completion?()
        continue
      }

      update(item, index: index, withAnimation: animation) {
        if index == lastUpdate {
          completion?()
        }
      }
    }
  }

  /// Reload spot with ItemChanges.
  ///
  /// - parameter changes:          A collection of changes; inserations, updates, reloads, deletions and updated children.
  /// - parameter animation:        A Animation that is used when performing the mutation.
  /// - parameter updateDataSource: A closure to update your data source.
  /// - parameter completion:       A completion closure that runs when your updates are done.
  public func reloadIfNeeded(_ changes: ItemChanges, withAnimation animation: Animation = .automatic, updateDataSource: () -> Void, completion: Completion) {
    tableView.process((insertions: changes.insertions, reloads: changes.reloads, deletions: changes.deletions), withAnimation: animation, updateDataSource: updateDataSource) { [weak self] in
      guard let weakSelf = self else { completion?(); return }

      if changes.updates.isEmpty {
        weakSelf.process(changes.updatedChildren, withAnimation: animation, completion: completion)
      } else {
        weakSelf.process(changes.updates) {
          weakSelf.process(changes.updatedChildren, withAnimation: animation, completion: completion)
        }
      }
    }
  }
}
