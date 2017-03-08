#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif

/// A class protocol that is used for all components inside of Controller
public protocol CoreComponent: class {

  #if !os(OSX)
  static var headers: Registry { get set }
  #endif
  static var views: Registry { get set }
  static var layout: Layout { get set }

  /// Child components
  var compositeComponents: [CompositeComponent] { get set }

  #if !os(OSX)
    /// A SpotsFocusDelegate object
    weak var focusDelegate: ComponentFocusDelegate? { get set }
  #endif

  /// A ComponentDelegate object
  weak var delegate: ComponentDelegate? { get set }

  /// The index of a CoreComponent object
  var index: Int { get }
  /// A computed value for the size of the CoreComponent object
  var computedHeight: CGFloat { get }
  /// The component of a CoreComponent object
  var model: ComponentModel { get set }
  /// A configuration closure for a ItemConfigurable object
  var configure: ((ItemConfigurable) -> Void)? { get set }
  /// A cache for a CoreComponent object
  var stateCache: StateCache? { get }
  /// Indicator to calculate the height based on content
  var usesDynamicHeight: Bool { get }
  /// The user interface that will be used to represent The component.
  var userInterface: UserInterface? { get }
  /// Return a CoreComponent object as a UIScrollView
  var view: ScrollView { get }

  #if os(OSX)
    /// The current responder for the CoreComponent object, only available on macOS.
    var responder: NSResponder { get }
    /// The next responder for the CoreComponent object, only available on macOS.
    var nextResponder: NSResponder? { get set }
  #endif

  /// Initialize a CoreComponent object with a ComponentModel.
  ///
  /// - parameter component: The component that the CoreComponent object should be initialized with.
  ///
  /// - returns: An initialized CoreComponent object.
  init(model: ComponentModel)

  /// Setup CoreComponent object with size
  func setup(_ size: CGSize)

  func ui<T>(at index: Int) -> T?

  /// Append item to collection with animation
  ///
  /// - parameter item: The view model that you want to append.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  func append(_ item: Item, withAnimation animation: Animation, completion: Completion)

  /// Append a collection of items to collection with animation
  ///
  /// - parameter items:      A collection of view models that you want to insert
  /// - parameter animation:  The animation that should be used (currently not in use)
  /// - parameter completion: A completion closure that is executed in the main queue.
  func append(_ items: [Item], withAnimation animation: Animation, completion: Completion)

  /// Insert item into collection at index.
  ///
  /// - parameter item:       The view model that you want to insert.
  /// - parameter index:      The index where the new Item should be inserted.
  /// - parameter animation:  A Animation that is used when performing the mutation (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  func insert(_ item: Item, index: Int, withAnimation animation: Animation, completion: Completion)

  /// Prepend a collection items to the collection with animation
  ///
  /// - parameter items:      A collection of view model that you want to prepend
  /// - parameter animation:  A Animation that is used when performing the mutation (currently not in use)
  /// - parameter completion: A completion closure that is executed in the main queue.
  func prepend(_ items: [Item], withAnimation animation: Animation, completion: Completion)

  /// Delete item from collection with animation
  ///
  /// - parameter item:       The view model that you want to remove.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  func delete(_ item: Item, withAnimation animation: Animation, completion: Completion)

  /// Delete items from collection with animation
  ///
  /// - parameter items:      A collection of view models that you want to delete.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  func delete(_ item: [Item], withAnimation animation: Animation, completion: Completion)

  /// Delete item at index with animation
  ///
  /// - parameter index:      The index of the view model that you want to remove.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been removed.
  func delete(_ index: Int, withAnimation animation: Animation, completion: Completion)

  /// Delete a collection
  ///
  /// - parameter indexes:    An array of indexes that you want to remove.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been removed.
  func delete(_ indexes: [Int], withAnimation animation: Animation, completion: Completion)

  /// Update item at index with new item.
  ///
  /// - parameter item:       The new update view model that you want to update at an index.
  /// - parameter index:      The index of the view model, defaults to 0.
  /// - parameter animation:  A Animation that is used when performing the mutation (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been removed.
  func update(_ item: Item, index: Int, withAnimation animation: Animation, completion: Completion)

  /// Reloads a spot only if it changes
  ///
  /// - parameter items:      A collection of Items
  /// - parameter animation:  The animation that should be used (only works for Listable objects)
  /// - parameter completion: A completion closure that is performed when all mutations are performed
  func reloadIfNeeded(_ items: [Item], withAnimation animation: Animation, completion: Completion)

  /// Reload spot with ItemChanges.
  ///
  /// - parameter changes:          A collection of changes: inserations, updates, reloads, deletions and updated children.
  /// - parameter animation:        A Animation that is used when performing the mutation.
  /// - parameter updateDataSource: A closure to update your data source.
  /// - parameter completion:       A completion closure that runs when your updates are done.
  func reloadIfNeeded(_ changes: ItemChanges, withAnimation animation: Animation, updateDataSource: () -> Void, completion: Completion)

  /// Reload with indexes
  ///
  /// - parameter indexes:    An array of integers that you want to reload, default is nil.
  /// - parameter animation:  Perform reload animation.
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been reloaded.
  func reload(_ indexes: [Int]?, withAnimation animation: Animation, completion: Completion)

  /// Layout using size
  /// - parameter size: A CGSize to set the width of the UI view
  ///
  func layout(_ size: CGSize)

  /// Perform internal preperations for a CoreComponent object
  func register()

  /// Scroll to Item matching predicate
  ///
  /// - parameter includeElement: A filter predicate to find a view model
  ///
  /// - returns: A calculate CGFloat based on what the includeElement matches
  func scrollTo(_ includeElement: (Item) -> Bool) -> CGFloat

  func sizeForItem(at indexPath: IndexPath) -> CGSize

  #if os(OSX)
  /// Unselect any selected views inside of The component.
  func deselect()
  #endif

  func beforeUpdate()
  func afterUpdate()
  func configure(with layout: Layout)
}
