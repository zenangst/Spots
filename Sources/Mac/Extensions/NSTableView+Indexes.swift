import Cocoa

public extension NSTableView {

  func insert(indexes: [Int], section: Int = 0, animation: NSTableViewAnimationOptions = .EffectFade, completion: (() -> Void)? = nil) {
    let indexPaths = NSMutableIndexSet()
    indexes.forEach { indexPaths.addIndex($0) }
    performUpdates({ insertRowsAtIndexes(indexPaths, withAnimation: animation) },
                   endClosure: completion)

  }

  func reload(indexes: [Int], section: Int = 0, animation: NSTableViewAnimationOptions = .EffectFade, completion: (() -> Void)? = nil) {
    let indexPaths = NSMutableIndexSet()
    indexes.forEach { indexPaths.addIndex($0) }
    performUpdates({ reloadDataForRowIndexes(indexPaths, columnIndexes: NSIndexSet(index: 0)) },
                   endClosure: completion)
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
