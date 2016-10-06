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
  /// A SpotsCompositeDelegate object
  weak var spotsCompositeDelegate: SpotsCompositeDelegate? { get set }
  #endif

  /// A SpotsDelegate object
  weak var spotsDelegate: SpotsDelegate? { get set }

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
    var responder: NSResponder { get }
    var nextResponder: NSResponder? { get set }
  #endif

  /**
   Initialize a Spotable object with a Component

   - parameter component: The component that the Spotable object should be initialized with
   - returns: A Spotable object
   */
  init(component: Component)

  /// Setup Spotable object with size
  func setup(_ size: CGSize)
  /// Append view model to a Spotable object
  func append(_ item: Item, withAnimation animation: SpotsAnimation, completion: Completion)
  /// Append a collection of view models to Spotable object
  func append(_ items: [Item], withAnimation animation: SpotsAnimation, completion: Completion)
  /// Prepend view models to a Spotable object
  func prepend(_ items: [Item], withAnimation animation: SpotsAnimation, completion: Completion)
  /// Insert view model to a Spotable object
  func insert(_ item: Item, index: Int, withAnimation animation: SpotsAnimation, completion: Completion)
  /// Update view model to a Spotable object
  func update(_ item: Item, index: Int, withAnimation animation: SpotsAnimation, completion: Completion)
  /// Delete view model from a Spotable object
  func delete(_ item: Item, withAnimation animation: SpotsAnimation, completion: Completion)
  /// Delete a collection of view models from a Spotable object
  func delete(_ item: [Item], withAnimation animation: SpotsAnimation, completion: Completion)
  /// Delete view model at index with animation from a Spotable object
  func delete(_ index: Int, withAnimation animation: SpotsAnimation, completion: Completion)
  /// Delete view model indexes with animation from a Spotable object
  func delete(_ indexes: [Int], withAnimation animation: SpotsAnimation, completion: Completion)
  /// Reload view model indexes with animation in a Spotable object
  func reload(_ indexes: [Int]?, withAnimation animation: SpotsAnimation, completion: Completion)
  func reloadIfNeeded(_ items: [Item], withAnimation animation: SpotsAnimation, completion: Completion)
  /// Reload view models if needed using change set
  func reloadIfNeeded(_ changes: ItemChanges, withAnimation animation: SpotsAnimation, updateDataSource: () -> Void, completion: Completion)

  /// Return a Spotable object as a UIScrollView
  func render() -> ScrollView
  /// Layout Spotable object using size
  func layout(_ size: CGSize)
  /// Perform internal preperations for a Spotable object
  func register()
  /// Scroll to view model using predicate
  func scrollTo(_ includeElement: (Item) -> Bool) -> CGFloat

  func sizeForItem(at indexPath: IndexPath) -> CGSize

  #if os(OSX)
  func deselect()
  #endif
}
