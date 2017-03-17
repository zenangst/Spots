#if os(OSX)
  import Foundation
#else
  import UIKit
#endif

import Cache

public protocol SpotsProtocol: class {

  /// A closure that is called when the controller is reloaded with components
  static var componentsDidReloadComponentModels: ((_ controller: Controller) -> Void)? { get set }
  /// A StateCache object
  var stateCache: StateCache? { get set }
  /// The internal SpotsScrollView
  var scrollView: SpotsScrollView { get }
  /// A delegate that conforms to ComponentDelegate
  var delegate: ComponentDelegate? { get }
  /// A collection of Component objects
  var components: [Component] { get set }
  /// An array of refresh position to avoid calling multiple refreshes
  var refreshPositions: [CGFloat] { get set }
  /// A view controller view
  #if os(OSX)
  var view: View { get }
  #else
  var view: View! { get }
  #endif

  /// A dictionary representation of the controller
  var dictionary: [String : Any] { get }

  #if os(iOS)
  var refreshDelegate: RefreshDelegate? { get set }
  #endif

  #if DEVMODE
  /// A dispatch queue is a lightweight object to which your application submits blocks for subsequent execution.
  var fileQueue: DispatchQueue { get }
  /// An identifier for the type system object being monitored by a dispatch source.
  var source: DispatchSourceFileSystemObject? { get set }
  #endif

  /// Set up components.
  ///
  /// - parameter animated: An optional animation closure that is invoked when setting up the component.
  func setupComponents(animated: ((_ view: View) -> Void)?)

  /// Set up Spot at index
  ///
  /// - parameter index: The index of the component.
  /// - parameter component:  The component that is going to be setup
  func setupComponent(at index: Int, component: Component)

  /// A generic look up method for resolving components using a closure
  ///
  /// - parameter closure: A closure to perform actions on a component
  ///
  /// - returns: An optional Component object
  func resolve(component closure: (_ index: Int, _ component: Component) -> Bool) -> Component?

  #if os(OSX)
  init(components: [Component], backgroundType: ControllerBackground)
  #else
  /// A required initializer for initializing a controller with Component objects
  ///
  /// - parameter components: A collection of Component objects that should be setup and be added to the view hierarchy.
  ///
  /// - returns: An initalized controller.
  init(components: [Component])
  #endif
}
