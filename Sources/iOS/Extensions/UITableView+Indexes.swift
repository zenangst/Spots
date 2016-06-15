import UIKit

public extension UITableView {

  func insert(indexes: [Int], section: Int = 0, animation: UITableViewRowAnimation = .Automatic) {
    let indexPaths = indexes.map { NSIndexPath(forRow: $0, inSection: section) }

    if animation == .None { UIView.setAnimationsEnabled(false) }
    performUpdates { insertRowsAtIndexPaths(indexPaths, withRowAnimation: animation) }
    if animation == .None { UIView.setAnimationsEnabled(true) }
  }

  func reload(indexes: [Int], section: Int = 0, animation: UITableViewRowAnimation = .Automatic) {
    let indexPaths = indexes.map { NSIndexPath(forRow: $0, inSection: section) }
    if animation == .None { UIView.setAnimationsEnabled(false) }
    performUpdates { reloadRowsAtIndexPaths(indexPaths, withRowAnimation: animation) }
    if animation == .None { UIView.setAnimationsEnabled(true) }
  }

  func delete(indexes: [Int], section: Int = 0, animation: UITableViewRowAnimation = .Automatic) {
    let indexPaths = indexes.map { NSIndexPath(forRow: $0, inSection: section) }
    if animation == .None { UIView.setAnimationsEnabled(false) }
    performUpdates { deleteRowsAtIndexPaths(indexPaths, withRowAnimation: animation) }
    if animation == .None { UIView.setAnimationsEnabled(true) }
  }

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
