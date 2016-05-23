#if os(iOS)
import UIKit
#else
import Cocoa
#endif
import Brick

/// A class protocol that is used for all components inside of SpotsController
public protocol Spotable: class {

  /// A view registry that is used internally when resolving kind to the corresponding spot.
  static var views: ViewRegistry { get }
  /// The default view type for the spotable object
  #if os(iOS)
  static var defaultView: UIView.Type { get set }
  #else
  static var defaultView: NSView.Type { get set }
  #endif
  /// The default kind to fall back to if the view model kind does not exist when trying to display the spotable item
  static var defaultKind: StringConvertible { get }

  weak var spotsDelegate: SpotsDelegate? { get set }

  var index: Int { get set }
  var component: Component { get set }
  var configure: (SpotConfigurable -> Void)? { get set }
  var stateCache: SpotCache? { get }

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

  /// Perform internal preperations for a Spotable object
  func prepare()

#if os(iOS)
  /// Return a Spotable object as a ScrollView
  func render() -> ScrollView
  /// Layout Spotable object using size
  func layout(size: CGSize)
  /// Scroll to view model using predicate
  func scrollTo(@noescape includeElement: (ViewModel) -> Bool) -> CGFloat
#else
  func render() -> RegularView
#endif
}
