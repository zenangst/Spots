import UIKit

public extension UITableView {

  ///  A convenience method for performing inserts on a UITableView
  ///  - parameter indexes: A collection integers
  ///  - parameter section: The section you want to update
  ///  - parameter animation: A constant that indicates how the reloading is to be animated
  func insert(_ indexes: [Int], section: Int = 0, animation: UITableViewRowAnimation = .automatic) {
    let indexPaths = indexes.map { IndexPath(row: $0, section: section) }

    if animation == .none { UIView.setAnimationsEnabled(false) }
    performUpdates { insertRows(at: indexPaths, with: animation) }
    if animation == .none { UIView.setAnimationsEnabled(true) }
  }

  /// A convenience method for performing inserts on a UITableView
  /// - parameter indexes: A collection integers
  /// - parameter section: The section you want to update
  /// - parameter animation: A constant that indicates how the reloading is to be animated
  func reload(_ indexes: [Int], section: Int = 0, animation: UITableViewRowAnimation = .automatic) {
    let indexPaths = indexes.map { IndexPath(row: $0, section: section) }
    if animation == .none { UIView.setAnimationsEnabled(false) }
    performUpdates { reloadRows(at: indexPaths, with: animation) }
    if animation == .none { UIView.setAnimationsEnabled(true) }
  }

  /// A convenience method for performing inserts on a UITableView
  /// - parameter indexes: A collection integers
  /// - parameter section: The section you want to update
  /// - parameter animation: A constant that indicates how the reloading is to be animated

  func delete(_ indexes: [Int], section: Int = 0, animation: UITableViewRowAnimation = .automatic) {
    let indexPaths = indexes.map { IndexPath(row: $0, section: section) }
    if animation == .none { UIView.setAnimationsEnabled(false) }
    performUpdates { deleteRows(at: indexPaths, with: animation) }
    if animation == .none { UIView.setAnimationsEnabled(true) }
  }


  /// Process a collection of changes
  ///
  /// - parameter changes:          A tuple with insertions, reloads and delctions
  /// - parameter animation:        The animation that should be used to perform the updates
  /// - parameter section:          The section that will be updates
  /// - parameter updateDataSource: A closure that is used to update the data source before performing the updates on the UI
  /// - parameter completion:       A completion closure that will run when both data source and UI is updated
  func process(_ changes: (insertions: [Int], reloads: [Int], deletions: [Int]),
               withAnimation animation: UITableViewRowAnimation = .automatic,
               section: Int = 0,
               updateDataSource: () -> Void,
               completion: ((()) -> Void)? = nil) {
    let insertions = changes.insertions.map { IndexPath(row: $0, section: section) }
    let reloads = changes.reloads.map { IndexPath(row: $0, section: section) }
    let deletions = changes.deletions.map { IndexPath(row: $0, section: section) }

    updateDataSource()
    beginUpdates()
    deleteRows(at: deletions, with: animation)
    insertRows(at: insertions, with: animation)
    reloadRows(at: reloads, with: animation)
    completion?()
    endUpdates()
  }

  /// A convenience method for performing inserts on a UITableView
  /// - parameter section: The section you want to update
  /// - parameter animation: A constant that indicates how the reloading is to be animated
  func reloadSection(_ section: Int = 0, animation: UITableViewRowAnimation = .automatic) {
    if animation == .none { UIView.setAnimationsEnabled(false) }
    performUpdates {
      reloadSections(IndexSet(integer: section), with: animation)
    }
    if animation == .none { UIView.setAnimationsEnabled(true) }
  }


  /// Perform updates with closure
  ///
  /// - parameter closure: A closure that contains the operations that should be performed within the context
  fileprivate func performUpdates(_ closure: () -> Void) {
    beginUpdates()
    closure()
    endUpdates()
  }
}
