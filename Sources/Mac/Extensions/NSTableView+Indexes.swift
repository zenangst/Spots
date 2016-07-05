import Cocoa

public extension NSTableView {

  func insert(indexes: [Int], section: Int = 0, animation: NSTableViewAnimationOptions = .EffectFade, completion: (() -> Void)? = nil) {
    let indexPaths = NSMutableIndexSet()
    indexes.forEach { indexPaths.addIndex($0) }
    performUpdates({ insertRowsAtIndexes(indexPaths, withAnimation: animation) },
                   endClosure: completion)

  }

  func reload(indexes: [Int], section: Int = 0, animation: NSTableViewAnimationOptions = .EffectFade, completion: (() -> Void)? = nil) {
    /** Manually handle reloading of the cell as reloadDataForRowIndexes does not seems to work with view based table views
     - "For NSView-based table views, this method drops the view-cells in the table row, but not the NSTableRowView instances."
    */
    indexes.forEach { index in
      if let view = rowViewAtRow(index, makeIfNecessary: false) as? SpotConfigurable,
      adapter = dataSource() as? ListAdapter {
        var item = adapter.spot.component.items[index]
        view.configure(&item)
      }
    }

    completion?()
  }

  func delete(indexes: [Int], animation: NSTableViewAnimationOptions = .EffectFade, completion: (() -> Void)? = nil) {
    let indexPaths = NSMutableIndexSet()
    indexes.forEach { indexPaths.addIndex($0) }
    performUpdates({ removeRowsAtIndexes(indexPaths, withAnimation: animation) },
                   endClosure: completion)
  }

  private func performUpdates(@noescape closure: () -> Void, endClosure: (() -> Void)? = nil) {
    beginUpdates()
    closure()
    endUpdates()
    endClosure?()
  }
}
