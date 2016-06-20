import UIKit

public extension UITableView {

  /**
   A convenience method for performing inserts on a UITableView
   - Parameter indexes: A collection integers
   - Parameter section: The section you want to update
   - Parameter animation: A constant that indicates how the reloading is to be animated
   **/
  func insert(indexes: [Int], section: Int = 0, animation: UITableViewRowAnimation = .Automatic) {
    let indexPaths = indexes.map { NSIndexPath(forRow: $0, inSection: section) }

    if animation == .None { UIView.setAnimationsEnabled(false) }
    performUpdates { insertRowsAtIndexPaths(indexPaths, withRowAnimation: animation) }
    if animation == .None { UIView.setAnimationsEnabled(true) }
  }

  /**
   A convenience method for performing inserts on a UITableView
   - Parameter indexes: A collection integers
   - Parameter section: The section you want to update
   - Parameter animation: A constant that indicates how the reloading is to be animated
   **/
  func reload(indexes: [Int], section: Int = 0, animation: UITableViewRowAnimation = .Automatic) {
    let indexPaths = indexes.map { NSIndexPath(forRow: $0, inSection: section) }
    if animation == .None { UIView.setAnimationsEnabled(false) }
    performUpdates { reloadRowsAtIndexPaths(indexPaths, withRowAnimation: animation) }
    if animation == .None { UIView.setAnimationsEnabled(true) }
  }

  /**
   A convenience method for performing inserts on a UITableView
   - Parameter indexes: A collection integers
   - Parameter section: The section you want to update
   - Parameter animation: A constant that indicates how the reloading is to be animated
   **/
  func delete(indexes: [Int], section: Int = 0, animation: UITableViewRowAnimation = .Automatic) {
    let indexPaths = indexes.map { NSIndexPath(forRow: $0, inSection: section) }
    if animation == .None { UIView.setAnimationsEnabled(false) }
    performUpdates { deleteRowsAtIndexPaths(indexPaths, withRowAnimation: animation) }
    if animation == .None { UIView.setAnimationsEnabled(true) }
  }

  /**
   A convenience method for performing inserts on a UITableView
   - Parameter section: The section you want to update
   - Parameter animation: A constant that indicates how the reloading is to be animated
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
