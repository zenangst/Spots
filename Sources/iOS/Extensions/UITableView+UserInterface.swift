import UIKit

extension UITableView: UserInterface {

  public var selectedIndex: Int {
    return indexPathForSelectedRow?.row ?? 0
  }

  @available(iOS 9.0, *)
  public var focusedIndex: Int {
    updateFocusIfNeeded()

    return delegate?.indexPathForPreferredFocusedView?(in: self)?.row ?? 0
  }

  /// Focus on item at index
  ///
  /// - parameter index: The index of the item you want to select.
  @available(iOS 9.0, *)
  public func focusOn(itemAt index: Int) {
    guard index < numberOfRows(inSection: 0) else {
      return
    }

    select(itemAt: index, animated: true)
    setNeedsFocusUpdate()
    deselect(itemAt: index, animated: true)
  }

  /// Select item at index
  ///
  /// - parameter index: The index of the item you want to select.
  /// - parameter animated: Performs an animation if set to true
  public func select(itemAt index: Int, animated: Bool = true) {
    guard index < numberOfRows(inSection: 0) else {
      return
    }

    selectRow(at: IndexPath(row: index, section: 0), animated: animated, scrollPosition: .none)
  }

  /// Deselect item at index
  ///
  /// - parameter index: The index of the item you want to deselect.
  /// - parameter animated: Performs an animation if set to true
  public func deselect(itemAt index: Int, animated: Bool = true) {
    guard index < numberOfRows(inSection: 0) else {
      return
    }

    deselectRow(at: IndexPath(row: index, section: 0), animated: animated)
  }

  public func view<T>(at index: Int) -> T? {
    return cellForRow(at: IndexPath(row: index, section: 0)) as? T
  }

  public func reloadDataSource() {
    reloadData()
  }

  ///  A convenience method for performing inserts on a UITableView
  ///
  ///  - parameter indexes: A collection integers
  ///  - parameter section: The section you want to update
  ///  - parameter animation: A constant that indicates how the reloading is to be animated
  public func insert(_ indexes: [Int], withAnimation animation: Animation = .automatic, completion: (() -> Void)? = nil) {
    let indexPaths = indexes.map { IndexPath(row: $0, section: 0) }

    if animation == .none { UIView.setAnimationsEnabled(false) }
    performUpdates { insertRows(at: indexPaths, with: animation.tableViewAnimation) }
    if animation == .none { UIView.setAnimationsEnabled(true) }
    completion?()
  }

  /// A convenience method for performing reloads on a UITableView
  ///
  /// - parameter indexes: A collection integers
  /// - parameter section: The section you want to update
  /// - parameter animation: A constant that indicates how the reloading is to be animated
  public func reload(_ indexes: [Int], withAnimation animation: Animation = .automatic, completion: (() -> Void)? = nil) {
    let indexPaths = indexes.map { IndexPath(row: $0, section: 0) }

    if animation == .none {
      UIView.setAnimationsEnabled(false)
    }

    if !indexPaths.isEmpty {
      performUpdates {
        reloadRows(at: indexPaths, with: animation.tableViewAnimation)
      }
    } else {
      reloadDataSource()
    }

    if animation == .none {
      UIView.setAnimationsEnabled(true)
    }

    completion?()
  }

  /// A convenience method for performing deletions on a UITableView
  ///
  /// - parameter indexes: A collection integers
  /// - parameter section: The section you want to update
  /// - parameter animation: A constant that indicates how the reloading is to be animated
  public func delete(_ indexes: [Int], withAnimation animation: Animation = .automatic, completion: (() -> Void)? = nil) {
    let indexPaths = indexes.map { IndexPath(row: $0, section: 0) }
    if animation == .none { UIView.setAnimationsEnabled(false) }
    performUpdates { deleteRows(at: indexPaths, with: animation.tableViewAnimation) }
    if animation == .none { UIView.setAnimationsEnabled(true) }
    completion?()
  }

  /// Process a collection of changes
  ///
  /// - parameter changes:          A tuple with insertions, reloads and deletions
  /// - parameter animation:        The animation that should be used to perform the updates
  /// - parameter section:          The section that will be updated
  /// - parameter updateDataSource: A closure that is used to update the data source before performing the updates on the UI
  /// - parameter completion:       A completion closure that will run when both data source and UI is updated
  public func process(_ changes: (insertions: [Int], reloads: [Int], deletions: [Int], childUpdates: [Int]),
               withAnimation animation: Animation = .automatic,
               updateDataSource: () -> Void,
               completion: ((()) -> Void)? = nil) {
    let insertions = changes.insertions.map { IndexPath(row: $0, section: 0) }
    let reloads = changes.reloads.map { IndexPath(row: $0, section: 0) }
    let deletions = changes.deletions.map { IndexPath(row: $0, section: 0) }

    updateDataSource()

    if insertions.isEmpty &&
      reloads.isEmpty &&
      deletions.isEmpty &&
      changes.childUpdates.isEmpty {
      completion?()
      return
    }

    beginUpdates()
    deleteRows(at: deletions, with: animation.tableViewAnimation)
    insertRows(at: insertions, with: animation.tableViewAnimation)
    reloadRows(at: reloads, with: animation.tableViewAnimation)
    endUpdates()
    completion?()
  }

  /// A convenience method for reloading section in a UITableView.
  ///
  /// - parameter section: The section you want to update.
  /// - parameter animation: A constant that indicates how the reloading is to be animated.
  /// - parameter completion: A completion closure that will run when the reload is done.
  public func reloadSection(_ section: Int = 0, withAnimation animation: Animation = .automatic, completion: (() -> Void)? = nil) {
    if animation == .none {
      UIView.setAnimationsEnabled(false)
    }

    performUpdates {
      reloadSections(IndexSet(integer: section), with: animation.tableViewAnimation)
    }
    if animation == .none {
      UIView.setAnimationsEnabled(true)
    }
    completion?()
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
