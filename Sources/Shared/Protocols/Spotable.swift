#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif

import Brick
import Sugar

/// A class protocol that is used for all components inside of SpotsController
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
  /// The component of a Spotable object
  var component: Component { get set }
  /// A configuration closure for a SpotConfigurable object
  var configure: (SpotConfigurable -> Void)? { get set }
  /// A cache for a Spotable object
  var stateCache: SpotCache? { get }
  /// A SpotAdapter
  var adapter: SpotAdapter? { get }

  #if os(OSX)
    var responder: NSResponder { get }
    var nextResponder: NSResponder? { get set }
  #endif

  /**
   Initialize a Spotable object with a Component

   - Parameter component: The component that the Spotable object should be initialized with
   - Returns: A Spotable object
   */
  init(component: Component)

  /// Setup Spotable object with size
  func setup(size: CGSize)
  /// Append view model to a Spotable object
  func append(item: ViewModel, withAnimation animation: SpotsAnimation, completion: Completion)
  /// Append a collection of view models to Spotable object
  func append(items: [ViewModel], withAnimation animation: SpotsAnimation, completion: Completion)
  /// Prepend view models to a Spotable object
  func prepend(items: [ViewModel], withAnimation animation: SpotsAnimation, completion: Completion)
  /// Insert view model to a Spotable object
  func insert(item: ViewModel, index: Int, withAnimation animation: SpotsAnimation, completion: Completion)
  /// Update view model to a Spotable object
  func update(item: ViewModel, index: Int, withAnimation animation: SpotsAnimation, completion: Completion)
  /// Delete view model from a Spotable object
  func delete(item: ViewModel, withAnimation animation: SpotsAnimation, completion: Completion)
  /// Delete a collection of view models from a Spotable object
  func delete(item: [ViewModel], withAnimation animation: SpotsAnimation, completion: Completion)
  /// Delete view model at index with animation from a Spotable object
  func delete(index: Int, withAnimation animation: SpotsAnimation, completion: Completion)
  /// Delete view model indexes with animation from a Spotable object
  func delete(indexes: [Int], withAnimation animation: SpotsAnimation, completion: Completion)
  /// Reload view model indexes with animation in a Spotable object
  func reload(indexes: [Int]?, withAnimation animation: SpotsAnimation, completion: Completion)

  func reloadIfNeeded(items: [ViewModel], withAnimation animation: SpotsAnimation, completion: Completion)
  /// Reload view models if needed using change set
  func reloadIfNeeded(changes: ViewModelChanges, withAnimation animation: SpotsAnimation, updateDataSource: () -> Void, completion: Completion)

  /// Return a Spotable object as a UIScrollView
  func render() -> ScrollView
  /// Layout Spotable object using size
  func layout(size: CGSize)
  /// Perform internal preperations for a Spotable object
  func register()
  /// Scroll to view model using predicate
  func scrollTo(@noescape includeElement: (ViewModel) -> Bool) -> CGFloat

  func spotHeight() -> CGFloat
  func sizeForItemAt(indexPath: NSIndexPath) -> CGSize

  #if os(OSX)
  func deselect()
  #endif
}
