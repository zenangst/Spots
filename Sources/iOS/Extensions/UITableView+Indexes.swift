import UIKit

public extension UITableView {

  /**
   A convenience method for performing inserts on a UITableView
   - parameter indexes: A collection integers
   - parameter section: The section you want to update
   - parameter animation: A constant that indicates how the reloading is to be animated
   **/
  func insert(indexes: [Int], section: Int = 0, animation: UITableViewRowAnimation = .Automatic) {
    let indexPaths = indexes.map { NSIndexPath(forRow: $0, inSection: section) }

    if animation == .None { UIView.setAnimationsEnabled(false) }
    performUpdates { insertRowsAtIndexPaths(indexPaths, withRowAnimation: animation) }
    if animation == .None { UIView.setAnimationsEnabled(true) }
  }

  /**
   A convenience method for performing inserts on a UITableView
   - parameter indexes: A collection integers
   - parameter section: The section you want to update
   - parameter animation: A constant that indicates how the reloading is to be animated
   **/
  func reload(indexes: [Int], section: Int = 0, animation: UITableViewRowAnimation = .Automatic) {
    let indexPaths = indexes.map { NSIndexPath(forRow: $0, inSection: section) }
    if animation == .None { UIView.setAnimationsEnabled(false) }
    performUpdates { reloadRowsAtIndexPaths(indexPaths, withRowAnimation: animation) }
    if animation == .None { UIView.setAnimationsEnabled(true) }
  }

  /**
   A convenience method for performing inserts on a UITableView
   - parameter indexes: A collection integers
   - parameter section: The section you want to update
   - parameter animation: A constant that indicates how the reloading is to be animated
   **/
  func delete(indexes: [Int], section: Int = 0, animation: UITableViewRowAnimation = .Automatic) {
    let indexPaths = indexes.map { NSIndexPath(forRow: $0, inSection: section) }
    if animation == .None { UIView.setAnimationsEnabled(false) }
    performUpdates { deleteRowsAtIndexPaths(indexPaths, withRowAnimation: animation) }
    if animation == .None { UIView.setAnimationsEnabled(true) }
  }

  /**
   Process a collection of changes

   - parameter changes:          A tuple with insertions, reloads and delctions
   - parameter animation:        The animation that should be used to perform the updates
   - parameter section:          The section that will be updates
   - parameter updateDataSource: A closure that is used to update the data source before performing the updates on the UI
   - parameter completion:       A completion closure that will run when both data source and UI is updated
   */
  func process(changes: (insertions: [Int], reloads: [Int], deletions: [Int]),
               withAnimation animation: UITableViewRowAnimation = .Automatic,
                             section: Int = 0,
                             updateDataSource: () -> Void,
                             completion: ((()) -> Void)? = nil) {
    let insertions = changes.insertions.map { NSIndexPath(forRow: $0, inSection: section) }
    let reloads = changes.reloads.map { NSIndexPath(forRow: $0, inSection: section) }
    let deletions = changes.deletions.map { NSIndexPath(forRow: $0, inSection: section) }

    updateDataSource()
    beginUpdates()
    deleteRowsAtIndexPaths(deletions, withRowAnimation: animation)
    insertRowsAtIndexPaths(insertions, withRowAnimation: animation)
    reloadRowsAtIndexPaths(reloads, withRowAnimation: animation)
    completion?()
    endUpdates()
  }

  /**
   A convenience method for performing inserts on a UITableView
   - parameter section: The section you want to update
   - parameter animation: A constant that indicates how the reloading is to be animated
   **/
  func reloadSection(section: Int = 0, animation: UITableViewRowAnimation = .Automatic) {
    if animation == .None { UIView.setAnimationsEnabled(false) }
    performUpdates {
      reloadSections(NSIndexSet(index: section), withRowAnimation: animation)
    }
    if animation == .None { UIView.setAnimationsEnabled(true) }
  }

  private func performUpdates(@noescape closure: () -> Void) {
    beginUpdates()
    closure()
    endUpdates()
  }
}
