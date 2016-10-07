#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif

import Brick

/// A class protocol that is used for all components inside of Controller
public protocol Spotable: class {

  static var views: Registry { get set }

  #if !os(OSX)
  /// A CompositeDelegate object
  weak var spotsCompositeDelegate: CompositeDelegate? { get set }
  #endif

  /// A SpotsDelegate object
  weak var delegate: SpotsDelegate? { get set }

  /// The index of a Spotable object
  var index: Int { get }
  /// A computed value for the size of the Spotable object
  var computedHeight: CGFloat { get }
  /// The component of a Spotable object
  var component: Component { get set }
  /// A configuration closure for a SpotConfigurable object
  var configure: ((SpotConfigurable) -> Void)? { get set }
  /// A cache for a Spotable object
  var stateCache: SpotCache? { get }
  /// A SpotAdapter
  var adapter: SpotAdapter? { get }
  /// Indicator to calculate the height based on content
  var usesDynamicHeight: Bool { get }

  #if os(OSX)
    /// The current responder for the Spotable object, only available on macOS.
    var responder: NSResponder { get }
    /// The next responder for the Spotable object, only available on macOS.
    var nextResponder: NSResponder? { get set }
  #endif

  /// Initialize a Spotable object with a Component.
  ///
  /// - parameter component: The component that the Spotable object should be initialized with.
  ///
  /// - returns: An initialized Spotable object.
  init(component: Component)

  /// Setup Spotable object with size
  func setup(_ size: CGSize)

  /// Append item to collection with animation
  ///
  /// - parameter item: The view model that you want to append.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  func append(_ item: Item, withAnimation animation: SpotsAnimation, completion: Completion)

  /// Append a collection of items to collection with animation
  ///
  /// - parameter items:      A collection of view models that you want to insert
  /// - parameter animation:  The animation that should be used (currently not in use)
  /// - parameter completion: A completion closure that is executed in the main queue.
  func append(_ items: [Item], withAnimation animation: SpotsAnimation, completion: Completion)

  /// Insert item into collection at index.
  ///
  /// - parameter item:       The view model that you want to insert.
  /// - parameter index:      The index where the new Item should be inserted.
  /// - parameter animation:  A SpotAnimation that is used when performing the mutation (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  func insert(_ item: Item, index: Int, withAnimation animation: SpotsAnimation, completion: Completion)

  /// Prepend a collection items to the collection with animation
  ///
  /// - parameter items:      A collection of view model that you want to prepend
  /// - parameter animation:  A SpotAnimation that is used when performing the mutation (currently not in use)
  /// - parameter completion: A completion closure that is executed in the main queue.
  func prepend(_ items: [Item], withAnimation animation: SpotsAnimation, completion: Completion)

  /// Delete item from collection with animation
  ///
  /// - parameter item:       The view model that you want to remove.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  func delete(_ item: Item, withAnimation animation: SpotsAnimation, completion: Completion)

  /// Delete items from collection with animation
  ///
  /// - parameter items:      A collection of view models that you want to delete.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  func delete(_ item: [Item], withAnimation animation: SpotsAnimation, completion: Completion)

  /// Delete item at index with animation
  ///
  /// - parameter index:      The index of the view model that you want to remove.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been removed.
  func delete(_ index: Int, withAnimation animation: SpotsAnimation, completion: Completion)

  /// Delete a collection
  ///
  /// - parameter indexes:    An array of indexes that you want to remove.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been removed.
  func delete(_ indexes: [Int], withAnimation animation: SpotsAnimation, completion: Completion)

  /// Update item at index with new item.
  ///
  /// - parameter item:       The new update view model that you want to update at an index.
  /// - parameter index:      The index of the view model, defaults to 0.
  /// - parameter animation:  A SpotAnimation that is used when performing the mutation (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been removed.
  func update(_ item: Item, index: Int, withAnimation animation: SpotsAnimation, completion: Completion)

  /// Reloads a spot only if it changes
  ///
  /// - parameter items:      A collection of Items
  /// - parameter animation:  The animation that should be used (only works for Listable objects)
  /// - parameter completion: A completion closure that is performed when all mutations are performed
  func reloadIfNeeded(_ items: [Item], withAnimation animation: SpotsAnimation, completion: Completion)

  /// Reload spot with ItemChanges.
  ///
  /// - parameter changes:          A collection of changes; inserations, updates, reloads, deletions and updated children.
  /// - parameter animation:        A SpotAnimation that is used when performing the mutation.
  /// - parameter updateDataSource: A closure to update your data source.
  /// - parameter completion:       A completion closure that runs when your updates are done.
  func reloadIfNeeded(_ changes: ItemChanges, withAnimation animation: SpotsAnimation, updateDataSource: () -> Void, completion: Completion)

  /// Reload with indexes
  ///
  /// - parameter indexes:    An array of integers that you want to reload, default is nil.
  /// - parameter animation:  Perform reload animation.
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been reloaded.
  func reload(_ indexes: [Int]?, withAnimation animation: SpotsAnimation, completion: Completion)

  /// Return a Spotable object as a UIScrollView
  ///
  /// - returns: The UI component that the Spotable object is based on cast as a ScrollView.
  func render() -> ScrollView

  /// Layout using size
  /// - parameter size: A CGSize to set the width of the UI view
  ///
  func layout(_ size: CGSize)

  /// Perform internal preperations for a Spotable object
  func register()

  /// Scroll to Item matching predicate
  ///
  /// - parameter includeElement: A filter predicate to find a view model
  ///
  /// - returns: A calculate CGFloat based on what the includeElement matches
  func scrollTo(_ includeElement: (Item) -> Bool) -> CGFloat

  func sizeForItem(at indexPath: IndexPath) -> CGSize

  #if os(OSX)
  /// Unselect any selected views inside of the spotable object.
  func deselect()
  #endif
}
