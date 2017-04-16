#if os(OSX)
  import Foundation
#else
  import UIKit
#endif

extension SpotsController {

  public typealias CompareClosure = ((_ lhs: [ComponentModel], _ rhs: [ComponentModel]) -> Bool)

  /**
   Reload all components.

   - parameter animated:   A boolean value that indicates if animations should be applied, defaults to true
   - parameter animation:  A ComponentAnimation struct that determines which animation that should be used for the updates
   - parameter completion: A completion block that is run when the reloading is done
   */
  public func reload(_ animated: Bool = true, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    manager.reload(controller: self, withAnimation: animation, completion: completion)
  }

  /// Reload if needed using JSON
  ///
  /// - parameter components: A collection of components that gets parsed into UI elements
  /// - parameter compare: A closure that is used for comparing a ComponentModel collections
  /// - parameter animated: An animation closure that can be used to perform custom animations when reloading
  /// - parameter completion: A closure that will be run after reload has been performed on all components
  public func reloadIfNeeded(_ components: [ComponentModel],
                             compare: @escaping CompareClosure = { lhs, rhs in return lhs !== rhs },
                             withAnimation animation: Animation = .automatic,
                             completion: Completion = nil) {
    manager.reloadIfNeeded(components: components,
                           controller: self,
                           compare: compare,
                           withAnimation: animation,
                           completion: completion)
  }

  ///Reload if needed using JSON
  ///
  /// - parameter json: A JSON dictionary that gets parsed into UI elements
  /// - parameter compare: A closure that is used for comparing a ComponentModel collections
  /// - parameter animated: An animation closure that can be used to perform custom animations when reloading
  /// - parameter completion: A closure that will be run after reload has been performed on all components
  public func reloadIfNeeded(_ json: [String : Any],
                             compare: @escaping CompareClosure = { lhs, rhs in return lhs !== rhs },
                             animated: ((_ view: View) -> Void)? = nil,
                             completion: Completion = nil) {
    manager.reloadIfNeeded(json,
                           controller: self,
                           compare: compare,
                           animated: animated,
                           completion: completion)
  }

  /// Reload with component models
  ///
  ///- parameter component models: A collection of component models.
  ///- parameter animated: An animation closure that can be used to perform custom animations when reloading
  ///- parameter completion: A closure that will be run after reload has been performed on all components
  public func reload(_ models: [ComponentModel], animated: ((_ view: View) -> Void)? = nil, completion: Completion = nil) {
    manager.reload(models: models,
                   controller: self,
                   animated: animated,
                   completion: completion)
  }

  /// Reload with JSON
  ///
  ///- parameter json: A JSON dictionary that gets parsed into UI elements
  ///- parameter animated: An animation closure that can be used to perform custom animations when reloading
  ///- parameter completion: A closure that will be run after reload has been performed on all components
  public func reload(_ json: [String : Any], animated: ((_ view: View) -> Void)? = nil, completion: Completion = nil) {
    manager.reload(json: json,
                   controller: self,
                   animated: animated,
                   completion: completion)
  }

  /**
   - parameter componentAtIndex: The index of the component that you want to perform updates on
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that is performed when the update is completed
   - parameter closure: A transform closure to perform the proper modification to the target component before updating the internals
   */
  public func update(componentAtIndex index: Int = 0, withAnimation animation: Animation = .automatic, withCompletion completion: Completion = nil, _ closure: (_ component: Component) -> Void) {
    manager.update(componentAtIndex: index,
                   controller: self,
                   withAnimation: animation,
                   withCompletion: completion,
                   closure)
  }

  /**
   Updates component only if the passed view models are not the same with the current ones.

   - parameter componentAtIndex: The index of the component that you want to perform updates on
   - parameter items: An array of view models
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that is run when the update is completed
   */
  public func updateIfNeeded(componentAtIndex index: Int = 0, items: [Item], withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    manager.updateIfNeeded(componentAtIndex: index,
                           controller: self,
                           items: items,
                           withAnimation: animation,
                           completion: completion)
  }

  /**
   - parameter item: The view model that you want to append
   - parameter componentIndex: The index of the component that you want to append to, defaults to 0
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the component has performed updates internally
   */
  public func append(_ item: Item, componentIndex: Int = 0, withAnimation animation: Animation = .none, completion: Completion = nil) {
    manager.append(item,
                   componentIndex: componentIndex,
                   controller: self,
                   withAnimation: animation,
                   completion: completion)
  }

  /**
   - parameter items: A collection of view models
   - parameter componentIndex: The index of the component that you want to append to, defaults to 0
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the component has performed updates internally
   */
  public func append(_ items: [Item], componentIndex: Int = 0, withAnimation animation: Animation = .none, completion: Completion = nil) {
    manager.append(items,
                   componentIndex: componentIndex,
                   controller: self,
                   withAnimation: animation,
                   completion: completion)
  }

  /**
   - parameter items: A collection of view models
   - parameter componentIndex: The index of the component that you want to prepend to, defaults to 0
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the component has performed updates internally
   */
  public func prepend(_ items: [Item], componentIndex: Int = 0, withAnimation animation: Animation = .none, completion: Completion = nil) {
    manager.prepend(items,
                   componentIndex: componentIndex,
                   controller: self,
                   withAnimation: animation,
                   completion: completion)
  }

  /**
   - parameter item: The view model that you want to insert
   - parameter index: The index that you want to insert the view model at
   - parameter componentIndex: The index of the component that you want to insert into
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the component has performed updates internally
   */
  public func insert(_ item: Item, index: Int = 0, componentIndex: Int, withAnimation animation: Animation = .none, completion: Completion = nil) {
    manager.insert(item,
                   index: index,
                   componentIndex: componentIndex,
                   controller: self,
                   withAnimation: animation,
                   completion: completion)
  }

  /// Update item at index inside a specific Component object
  ///
  /// - parameter item:       The view model that you want to update.
  /// - parameter index:      The index that you want to insert the view model at.
  /// - parameter componentIndex:  The index of the component that you want to update into.
  /// - parameter animation:  A Animation struct that determines which animation that should be used to perform the update.
  /// - parameter completion: A completion closure that will run after the component has performed updates internally.
  public func update(_ item: Item, index: Int = 0, componentIndex: Int, withAnimation animation: Animation = .none, completion: Completion = nil) {
    manager.update(item,
                   index: index,
                   componentIndex: componentIndex,
                   controller: self,
                   withAnimation: animation,
                   completion: completion)
  }

  /**
   - parameter indexes: An integer array of indexes that you want to update
   - parameter componentIndex: The index of the component that you want to update into
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the component has performed updates internally
   */
  public func update(_ indexes: [Int], componentIndex: Int = 0, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    manager.update(indexes,
                   componentIndex: componentIndex,
                   controller: self,
                   withAnimation: animation,
                   completion: completion)
  }

  /**
   - parameter index: The index of the view model that you want to remove
   - parameter componentIndex: The index of the component that you want to remove into
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the component has performed updates internally
   */
  public func delete(_ index: Int, componentIndex: Int = 0, withAnimation animation: Animation = .none, completion: Completion = nil) {
    manager.delete(index,
                   componentIndex: componentIndex,
                   controller: self,
                   withAnimation: animation,
                   completion: completion)
  }

  /**
   - parameter indexes: A collection of indexes for view models that you want to remove
   - parameter componentIndex: The index of the component that you want to remove into
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the component has performed updates internally
   */
  public func delete(_ indexes: [Int], componentIndex: Int = 0, withAnimation animation: Animation = .none, completion: Completion = nil) {
    manager.delete(indexes,
                   componentIndex: componentIndex,
                   controller: self,
                   withAnimation: animation,
                   completion: completion)
  }
}
