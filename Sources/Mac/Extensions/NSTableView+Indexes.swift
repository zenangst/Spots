import Cocoa

public extension NSTableView {

  func insert(_ indexes: [Int], section: Int = 0, animation: NSTableViewAnimationOptions = .effectFade, completion: (() -> Void)? = nil) {
    let indexPaths = NSMutableIndexSet()
    indexes.forEach { indexPaths.add($0) }
    performUpdates({ insertRows(at: indexPaths as IndexSet, withAnimation: animation) },
                   endClosure: completion)

  }

  func reload(_ indexes: [Int], section: Int = 0, animation: NSTableViewAnimationOptions = .effectFade, completion: (() -> Void)? = nil) {
    /** Manually handle reloading of the cell as reloadDataForRowIndexes does not seems to work with view based table views
     - "For NSView-based table views, this method drops the view-cells in the table row, but not the NSTableRowView instances."
    */
    indexes.forEach { index in
      if let view = rowView(atRow: index, makeIfNecessary: false) as? SpotConfigurable,
      let adapter = dataSource as? Listable {
        var item = adapter.component.items[index]
        view.configure(&item)
      }
    }

    completion?()
  }

  func delete(_ indexes: [Int], animation: NSTableViewAnimationOptions = .effectFade, completion: (() -> Void)? = nil) {
    let indexPaths = NSMutableIndexSet()
    indexes.forEach { indexPaths.add($0) }
    performUpdates({ removeRows(at: indexPaths as IndexSet, withAnimation: animation) },
                   endClosure: completion)
  }

  func process(_ changes: (insertions: [Int], reloads: [Int], deletions: [Int]),
               withAnimation animation: NSTableViewAnimationOptions = .effectFade,
                             section: Int = 0,
                             updateDataSource: () -> Void,
                             completion: ((()) -> Void)? = nil) {
    let insertionsSets = NSMutableIndexSet()
    changes.insertions.forEach { insertionsSets.add($0) }
    let reloadSets = NSMutableIndexSet()
    changes.reloads.forEach { reloadSets.add($0) }
    let deletionSets = NSMutableIndexSet()
    changes.deletions.forEach { deletionSets.add($0) }

    updateDataSource()
    beginUpdates()
    removeRows(at: deletionSets as IndexSet, withAnimation: animation)
    insertRows(at: insertionsSets as IndexSet, withAnimation: animation)

    for index in reloadSets {
      guard let view = rowView(atRow: index, makeIfNecessary: false) as? SpotConfigurable,
        let adapter = dataSource as? Listable else { continue }

      var item = adapter.component.items[index]
      view.configure(&item)
    }

    completion?()
    endUpdates()
  }

  fileprivate func performUpdates( _ closure: () -> Void, endClosure: (() -> Void)? = nil) {
    beginUpdates()
    closure()
    endUpdates()
    endClosure?()
  }
}
