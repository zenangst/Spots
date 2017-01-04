import Brick

/// A protocol used for composition inside Spotable objects
public protocol UserInterface: class {

  #if !os(OSX)
  /// The index of the current selected item
  var selectedIndex: Int { get }
  /// The index of the current focused item
  var focusedIndex: Int { get }

  /// Focus on item at index
  ///
  /// - parameter index: The index of the item you want to focus.
  func focusOn(itemAt index: Int)

  /// Select item at index
  ///
  /// - parameter index: The index of the item you want to select.
  /// - parameter animated: Performs an animation if set to true
  func select(itemAt index: Int, animated: Bool)

  /// Deselect item at index
  ///
  /// - parameter index: The index of the item you want to deselect.
  /// - parameter animated: Performs an animation if set to true
  func deselect(itemAt index: Int, animated: Bool)
  #endif

  /// Find a generic UI component at index
  ///
  /// - parameter index: The index of the UI that you are looking for.
  ///
  /// - returns: Find UI element with generic type inferred.
  func view<T>(at index: Int) -> T?

  ///  A convenience method for performing inserts on a UserInterface
  ///
  ///  - parameter indexes: A collection integers.
  ///  - parameter section: The section you want to update.
  ///  - parameter animation: A constant that indicates how the reloading is to be animated.
  func insert(_ indexes: [Int], withAnimation animation: Animation, completion: (() -> Void)?)

  /// A convenience method for performing reloads on a UserInterface
  ///
  /// - parameter indexes: A collection integers.
  /// - parameter section: The section you want to reload.
  /// - parameter animation: A constant that indicates how the reloading is to be animated.
  func reload(_ indexes: [Int], withAnimation animation: Animation, completion: (() -> Void)?)

  /// A convenience method for performing deletions on a UserInterface
  ///
  /// - parameter indexes: A collection integers
  /// - parameter section: The section you want to delete.
  /// - parameter animation: A constant that indicates how the reloading is to be animated.
  func delete(_ indexes: [Int], withAnimation animation: Animation, completion: (() -> Void)?)

  /// Process a collection of changes
  ///
  /// - parameter changes:          A tuple with insertions, reloads and delctions
  /// - parameter animation:        The animation that should be used to perform the updates
  /// - parameter section:          The section that will be updates
  /// - parameter updateDataSource: A closure that is used to update the data source before performing the updates on the UI
  /// - parameter completion:       A completion closure that will run when both data source and UI is updated
  func process(_ changes: (insertions: [Int], reloads: [Int], deletions: [Int], childUpdates: [Int]),
               withAnimation animation: Animation,
               updateDataSource: () -> Void,
               completion: ((()) -> Void)?)

  /// A convenience method for performing inserts on a UserInterface.
  ///
  /// - parameter section: The section you want to update.
  /// - parameter animation: A constant that indicates how the reloading is to be animated.
  /// - parameter completino: A completion closure that will run when the reload is done.
  func reloadSection(_ section: Int, withAnimation animation: Animation, completion: (() -> Void)?)

  /// A method that is invoked before the update occures.
  func beginUpdates()
  /// A method that is invoked after the update occures.
  func endUpdates()
  /// A proxy method to call reloadData
  func reloadDataSource()
}
