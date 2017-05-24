// swiftlint:disable type_body_length
#if os(OSX)
  import Foundation
#else
  import UIKit
#endif

/// SpotsControllerManager handles mutation on a controller level.
/// It relays mutating operations to `ComponentManger` when the affected `Component` has been resolved.
/// It supports both reloading with JSON payloads and with collections of `ComponentModel`'s.
/// Similar to `ComponentManager`, each mutating operation has a completion that will be invoked when
/// the operation reaches its end, this way you can respond to chained mutations on a controller level.
/// `SpotsControllerManager` also supports model diffing, which means that it will only insert, update, reload
/// or delete components or items that changed. This is supported on a `ComponentModel` level.
/// It can also pinpoint updates on a specific component by supplying the component index of the `Component`
/// that you which to mutate. `SpotsController` has a protocol extension which makes these method directly accessable
/// on the controller (see `SpotsController+SpotsControllerManager`).  `SpotsControllerManager` lives on `SpotsController`.
/// It is created during init and is publicly accessable via `.manager`. 
///
/// Usage:
///
/// 
/// ```
/// // Reload with a collection of `ComponentModel`s
/// controller.reloadIfNeeded(components: [componentModel, ...]) {}
/// ```
/// // Updating the item at index 0
/// ```
/// controller.update(item: Item(...), index: 0) {}
///
/// ```
///
public class SpotsControllerManager {

  /// A comparison closure type alias for comparing collections of component models.
  public typealias CompareClosure = ((_ lhs: [ComponentModel], _ rhs: [ComponentModel]) -> Bool)

  /**
   Reload all components.

   - parameter animation:  A ComponentAnimation struct that determines which animation that should be used for the updates
   - parameter completion: A completion block that is run when the reloading is done
   */
  public func reload(controller: SpotsController, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    var componentsLeft = controller.components.count

    Dispatch.main {
      controller.components.forEach { component in
        component.reload([], withAnimation: animation) {
          componentsLeft -= 1

          if componentsLeft == 0 {
            completion?()
          }
        }
      }
    }
  }

  /// Reload if needed using JSON
  ///
  /// - parameter components: A collection of components that gets parsed into UI elements
  /// - parameter compare: A closure that is used for comparing a ComponentModel collections
  /// - parameter animated: An animation closure that can be used to perform custom animations when reloading
  /// - parameter completion: A closure that will be run after reload has been performed on all components
  public func reloadIfNeeded(components: [ComponentModel],
                             controller: SpotsController,
                             compare: @escaping CompareClosure = { lhs, rhs in return lhs !== rhs },
                             withAnimation animation: Animation = .automatic,
                             completion: Completion = nil) {
    guard !components.isEmpty else {
      Dispatch.main {
        controller.components.forEach {
          $0.view.removeFromSuperview()
        }
        controller.components = []
        completion?()
      }
      return
    }

    Dispatch.interactive { [weak self] in
      guard let strongSelf = self else {
        completion?()
        return
      }

      let oldComponents = controller.components
      let oldComponentModels = oldComponents.map { $0.model }
      var newComponentModels = components

      /// Prepare default layouts for new components based of previous Component kind.
      for (index, _) in newComponentModels.enumerated() {
        guard index < oldComponentModels.count else {
          break
        }

        if newComponentModels[index].layout == nil {
          newComponentModels[index].layout = type(of: oldComponents[index]).layout
        }
      }

      guard compare(newComponentModels, oldComponentModels) else {
        Dispatch.main {
          controller.scrollView.layoutViews()
          SpotsController.componentsDidReloadComponentModels?(controller)
          completion?()
        }
        return
      }

      let changes = strongSelf.generateChanges(from: newComponentModels, and: oldComponentModels)

      strongSelf.process(changes: changes, controller: controller, components: newComponentModels, withAnimation: animation) {
        Dispatch.main {
          controller.scrollView.layoutSubviews()
          SpotsController.componentsDidReloadComponentModels?(controller)
          completion?()
        }
      }
    }
  }

  /// Generate a change set by comparing two component collections
  ///
  /// - parameter components:    A collection of components
  /// - parameter oldComponentModels: A collection of components
  ///
  /// - returns: A ComponentModelDiff struct
  func generateChanges(from models: [ComponentModel], and oldComponentModels: [ComponentModel]) -> [ComponentModelDiff] {
    let oldComponentModelCount = oldComponentModels.count
    var changes = [ComponentModelDiff]()
    for (index, model) in models.enumerated() {
      if index >= oldComponentModelCount {
        changes.append(.new)
        continue
      }

      changes.append(model.diff(model: oldComponentModels[index]))
    }

    if oldComponentModelCount > models.count {
      oldComponentModels[models.count..<oldComponentModels.count].forEach { _ in
        changes.append(.removed)
      }
    }

    return changes
  }

  /// Replace component at index
  ///
  /// - Parameters:
  ///   - index: The index of the component
  ///   - controller: A SpotsController
  ///   - newComponentModels: The new component model that should replace the existing component.
  ///   - yOffset: The y offset of the component.
  fileprivate func replaceComponent(atIndex index: Int, controller: SpotsController, newComponentModels: [ComponentModel], yOffset: inout CGFloat) {
    let component = Component(model: newComponentModels[index])
    let oldComponent = controller.components[index]

    /// Remove old composite components from superview and empty container
    for compositeComponent in oldComponent.compositeComponents {
      compositeComponent.component.view.removeFromSuperview()
    }
    oldComponent.compositeComponents = []

    component.view.frame = oldComponent.view.frame

    oldComponent.view.removeFromSuperview()
    controller.components[index] = component
    controller.scrollView.componentsView.insertSubview(component.view, at: index)
    controller.setupComponent(at: index, component: component)

    yOffset += component.view.frame.size.height
  }

  /// Insert new component at index.
  ///
  /// - Parameters:
  ///   - index: The index of the component
  ///   - controller: A SpotsController instance.
  ///   - newComponentModels: The new component model that should replace the existing component.
  ///   - yOffset: The y offset of the component.
  fileprivate func newComponent(atIndex index: Int, controller: SpotsController, newComponentModels: [ComponentModel], yOffset: inout CGFloat) {
    let component = Component(model: newComponentModels[index])
    controller.components.append(component)
    controller.setupComponent(at: index, component: component)

    yOffset += component.view.frame.size.height
  }

  /// Remove component at index
  ///
  /// - Parameters:
  ///   - index: The index of the component that should be removed.
  ///   - controller: A SpotsController instance.
  fileprivate func removeComponent(atIndex index: Int, controller: SpotsController) {
    guard index < controller.components.count else {
      return
    }
    controller.components[index].view.removeFromSuperview()
  }

  /// Set up items for a Component object
  ///
  /// - parameter index:         The index of the Component object
  /// - parameter controller:    A SpotsController instance.
  /// - parameter newComponentModels: A collection of new components
  /// - parameter animation:     A Animation that is used to determine which animation to use when performing the update
  /// - parameter closure:       A completion closure that is invoked when the setup of the new items is complete
  ///
  /// - returns: A boolean value that determines if the closure should run in `process(changes:)`
  fileprivate func setupItemsForComponent(atIndex index: Int, controller: SpotsController, newComponentModels: [ComponentModel], withAnimation animation: Animation = .automatic, completion: Completion = nil) -> Bool {
    guard let component = controller.component(at: index) else {
      return false
    }

    return updateComponentModel(newComponentModels[index],
                                on: component,
                                in: controller,
                                withAnimation: animation,
                                completion: completion)
  }

  /// Reload Component object with changes and new items.
  ///
  /// - parameter changes:   A ItemChanges tuple.
  /// - parameter controller:    A SpotsController instance.
  /// - parameter component:      The component that should be updated.
  /// - parameter newItems:  The new items that should be used to updated the data source.
  /// - parameter animation: The animation that should be used when updating.
  /// - parameter closure:   A completion closure.
  private func reload(with changes: (ItemChanges),
                      controller: SpotsController,
                      in component: Component,
                      newItems: [Item],
                      animation: Animation,
                      completion: (() -> Void)? = nil) {
    var offsets = [CGPoint]()

    component.reloadIfNeeded(changes, withAnimation: animation, updateDataSource: {
      for item in newItems {
        let results = component.compositeComponents.filter({ $0.itemIndex == item.index })
        for compositeComponent in results {
          offsets.append(compositeComponent.component.view.contentOffset)
        }
      }

      component.model.items = newItems
    }) {
      for (index, item) in newItems.enumerated() {
        guard index < controller.components.count else {
          break
        }

        let compositeComponents = controller.components[item.index].compositeComponents
          .filter({ $0.itemIndex == item.index })
        for (index, compositeComponent) in compositeComponents.enumerated() {
          guard index < offsets.count else {
            continue
          }

          compositeComponent.component.view.contentOffset = offsets[index]
        }
      }

      completion?()
    }
  }

  /// Reload Component object with less items
  ///
  /// - parameter changes:   A ItemChanges tuple.
  /// - parameter controller:    A SpotsController instance.
  /// - parameter component:      The component that should be updated.
  /// - parameter newItems:  The new items that should be used to updated the data source.
  /// - parameter animation: The animation that should be used when updating.
  /// - parameter closure:   A completion closure.
  private func reload(with changes: (ItemChanges),
                      controller: SpotsController,
                      in component: Component,
                      lessItems newItems: [Item],
                      animation: Animation,
                      completion: (() -> Void)? = nil) {
    component.reloadIfNeeded(changes, withAnimation: animation, updateDataSource: {
      component.model.items = newItems
    }) {
      guard !newItems.isEmpty else {
        completion?()
        return
      }

      let executeClosure = newItems.count - 1
      for (index, item) in newItems.enumerated() {
        let components = Parser.parse(item.children).map { $0.model }

        let oldComponents = controller.components.flatMap({
          $0.compositeComponents
        })

        for removedComponent in oldComponents {
          guard !components.contains(removedComponent.component.model) else {
            continue
          }

          if let index = removedComponent.component.parentComponent?.compositeComponents.index(of: removedComponent) {
            removedComponent.component.parentComponent?.compositeComponents.remove(at: index)
          }
        }

        if !component.model.items.filter({ !$0.children.isEmpty }).isEmpty {
          component.reload(nil, withAnimation: animation, completion: completion)
        } else {
          component.update(item, index: index, withAnimation: animation) {
            guard index == executeClosure else {
              return
            }
            completion?()
          }
        }
      }
    }
  }

  /// Reload Component object with more items
  ///
  /// - parameter changes:   A ItemChanges tuple.
  /// - parameter controller:    A SpotsController instance.
  /// - parameter component:      The component that should be updated.
  /// - parameter newItems:  The new items that should be used to updated the data source.
  /// - parameter animation: The animation that should be used when updating.
  /// - parameter closure:   A completion closure.
  private func reload(with changes: (ItemChanges),
                      controller: SpotsController,
                      in component: Component,
                      moreItems newItems: [Item],
                      animation: Animation,
                      completion: (() -> Void)? = nil) {
    component.reloadIfNeeded(changes, withAnimation: animation, updateDataSource: {
      component.model.items = newItems
    }) {
      if !component.model.items.filter({ !$0.children.isEmpty }).isEmpty {
        component.reload(nil, withAnimation: animation) {
          controller.scrollView.layoutSubviews()
          completion?()
        }
      } else {
        controller.scrollView.layoutSubviews()
        completion?()
      }
    }
  }

  /// Process a collection of component model diffs.
  ///
  /// - Parameters:
  ///   - changes: A collection of component model diffs.
  ///   - controller: A SpotsController instance.
  ///   - newComponentModels: A collection of new component models.
  ///   - animation: The animation that should be used when updating the components.
  ///   - completion: A completion closure that is run when the process is done.
  func process(changes: [ComponentModelDiff],
               controller: SpotsController,
               components newComponentModels: [ComponentModel],
               withAnimation animation: Animation = .automatic,
               completion: Completion = nil) {
    Dispatch.main { [weak self] in
      guard let strongSelf = self else {
        completion?()
        return
      }

      let finalCompletion = completion

      var yOffset: CGFloat = 0.0
      var runCompletion = true
      var completion: Completion = nil
      var lastItemChange: Int?

      for (index, change) in changes.enumerated() {
        if change == .items {
          lastItemChange = index
        }
      }

      for (index, change) in changes.enumerated() {
        switch change {
        case .identifier, .kind, .layout, .header, .footer, .meta:
          strongSelf.replaceComponent(atIndex: index, controller: controller, newComponentModels: newComponentModels, yOffset: &yOffset)
        case .new:
          strongSelf.newComponent(atIndex: index, controller: controller, newComponentModels: newComponentModels, yOffset: &yOffset)
        case .removed:
          strongSelf.removeComponent(atIndex: index, controller: controller)
        case .items:
          if index == lastItemChange {
            completion = finalCompletion
          }

          runCompletion = !strongSelf.setupItemsForComponent(atIndex: index,
                                                            controller: controller,
                                                            newComponentModels: newComponentModels,
                                                            withAnimation: animation,
                                                            completion: completion)
        case .none: continue
        }
      }

      for removedComponent in controller.components where removedComponent.view.superview == nil {
        if let index = controller.components.index(where: { removedComponent.view.isEqual($0.view) }) {
          controller.components.remove(at: index)
        }
      }

      if runCompletion {
        controller.scrollView.layoutSubviews()
        finalCompletion?()
      }
    }
  }

  ///Reload if needed using JSON
  ///
  /// - parameter json: A JSON dictionary that gets parsed into UI elements
  /// - parameter controller: A SpotsController instance.
  /// - parameter compare: A closure that is used for comparing a ComponentModel collections
  /// - parameter animated: An animation closure that can be used to perform custom animations when reloading
  /// - parameter completion: A closure that will be run after reload has been performed on all components
  public func reloadIfNeeded(_ json: [String : Any],
                             controller: SpotsController,
                             compare: @escaping CompareClosure = { lhs, rhs in return lhs !== rhs },
                             animated: ((_ view: View) -> Void)? = nil,
                             completion: Completion = nil) {
    Dispatch.main { [weak self] in
      guard let strongSelf = self else {
        completion?()
        return
      }

      let newComponents: [Component] = Parser.parse(json)
      let newComponentModels = newComponents.map { $0.model }
      let oldComponentModels = controller.components.map { $0.model }

      guard compare(newComponentModels, oldComponentModels) else {
        SpotsController.componentsDidReloadComponentModels?(controller)
        completion?()
        return
      }

      var offsets = [CGPoint]()
      let oldComposites = controller.components.flatMap { $0.compositeComponents }

      if newComponentModels.count == oldComponentModels.count {
        offsets = controller.components.map { $0.view.contentOffset }
      }

      controller.components = newComponents

      if controller.scrollView.superview == nil {
        controller.view.addSubview(controller.scrollView)
      }

      strongSelf.cleanUpComponentView(controller: controller)
      controller.setupComponents(animated: animated)

      let newComposites = controller.components.flatMap { $0.compositeComponents }

      for (index, compositeComponent) in oldComposites.enumerated() {
        if index == newComposites.count {
          break
        }

        newComposites[index].component.view.contentOffset = compositeComponent.component.view.contentOffset
      }

      completion?()

      offsets.enumerated().forEach {
        newComponents[$0.offset].view.contentOffset = $0.element
      }

      controller.scrollView.layoutSubviews()
      SpotsController.componentsDidReloadComponentModels?(controller)
    }
  }

  /// Reload with component models
  ///
  ///- parameter component models: A collection of component models.
  ///- parameter controller: A SpotsController instance.
  ///- parameter animated: An animation closure that can be used to perform custom animations when reloading
  ///- parameter completion: A closure that will be run after reload has been performed on all components
  public func reload(models: [ComponentModel], controller: SpotsController, animated: ((_ view: View) -> Void)? = nil, completion: Completion = nil) {
    Dispatch.main { [weak self] in
      guard let strongSelf = self else {
        completion?()
        return
      }

      controller.components = Parser.parse(models)

      if controller.scrollView.superview == nil {
        controller.view.addSubview(controller.scrollView)
      }

      let previousContentOffset = controller.scrollView.contentOffset

      strongSelf.cleanUpComponentView(controller: controller)
      controller.setupComponents(animated: animated)
      controller.components.forEach { component in
        component.afterUpdate()
      }

      SpotsController.componentsDidReloadComponentModels?(controller)
      controller.scrollView.layoutSubviews()
      controller.scrollView.contentOffset = previousContentOffset
      completion?()
    }
  }

  /// Reload with JSON
  ///
  ///- parameter json: A JSON dictionary that gets parsed into UI elements
  ///- parameter controller: A SpotsController instance.
  ///- parameter animated: An animation closure that can be used to perform custom animations when reloading
  ///- parameter completion: A closure that will be run after reload has been performed on all components
  public func reload(json: [String : Any], controller: SpotsController, animated: ((_ view: View) -> Void)? = nil, completion: Completion = nil) {
    Dispatch.main { [weak self] in
      guard let strongSelf = self else {
        completion?()
        return
      }

      controller.components = Parser.parse(json)

      if controller.scrollView.superview == nil {
        controller.view.addSubview(controller.scrollView)
      }

      let previousContentOffset = controller.scrollView.contentOffset

      strongSelf.cleanUpComponentView(controller: controller)
      controller.setupComponents(animated: animated)
      controller.components.forEach { component in
        component.afterUpdate()
      }

      SpotsController.componentsDidReloadComponentModels?(controller)
      controller.scrollView.layoutSubviews()
      controller.scrollView.contentOffset = previousContentOffset
      completion?()
    }
  }

  /**
   - parameter componentAtIndex: The index of the component that you want to perform updates on.
   - parameter controller: A SpotsController instance.
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update.
   - parameter completion: A completion closure that is performed when the update is completed.
   - parameter closure: A transform closure to perform the proper modification to the target component before updating the internals.
   */
  public func update(componentAtIndex index: Int = 0, controller: SpotsController, withAnimation animation: Animation = .automatic, withCompletion completion: Completion = nil, _ closure: (_ component: Component) -> Void) {
    guard let component = controller.component(at: index) else {
      assertionFailure("Could not resolve component at index: \(index).")
      controller.scrollView.layoutSubviews()
      completion?()
      return
    }

    closure(component)
    component.prepareItems()

    Dispatch.main {
      #if !os(OSX)
        if animation != .none {
          let isScrolling = controller.scrollView.isDragging == true || controller.scrollView.isTracking == true
          if let superview = component.view.superview, !isScrolling {
            component.view.frame.size.height = superview.frame.height
          }
        }
      #endif

      component.reload(nil, withAnimation: animation) {
        controller.scrollView.layoutSubviews()
        completion?()
      }
    }
  }

  /**
   Updates component only if the passed view models are not the same with the current ones.

   - parameter componentAtIndex: The index of the component that you want to perform updates on
   - parameter controller: A SpotsController instance.
   - parameter items: An array of view models
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that is run when the update is completed
   */
  public func updateIfNeeded(componentAtIndex index: Int = 0, controller: SpotsController, items: [Item], withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    guard let component = controller.component(at: index) else {
      assertionFailure("Could not resolve component at index: \(index).")
      controller.scrollView.layoutSubviews()
      completion?()
      return
    }

    var newModel = component.model
    newModel.items = items

    let didUpdate = updateComponentModel(newModel, on: component, in: controller, withAnimation: animation) {
      controller.scrollView.layoutSubviews()
      completion?()
    }

    /// `updateComponentWithModel` will not invoke the completion closure if there are no updates.
    /// Therefor we need to invoke it manually here.
    if !didUpdate {
      completion?()
    }
  }

  /**
   - parameter item: The view model that you want to append
   - parameter componentIndex: The index of the component that you want to append to, defaults to 0
   - parameter controller: A SpotsController instance.
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the component has performed updates internally
   */
  public func append(_ item: Item, componentIndex: Int = 0, controller: SpotsController, withAnimation animation: Animation = .none, completion: Completion = nil) {
    resolveComponent(atIndex: componentIndex, controller: controller, completion: completion) { component in
      component.append(item, withAnimation: animation, completion: completion)
    }
  }

  /**
   - parameter items: A collection of view models
   - parameter componentIndex: The index of the component that you want to append to, defaults to 0
   - parameter controller: A SpotsController instance.
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the component has performed updates internally
   */
  public func append(_ items: [Item], componentIndex: Int = 0, controller: SpotsController, withAnimation animation: Animation = .none, completion: Completion = nil) {
    resolveComponent(atIndex: componentIndex, controller: controller, completion: completion) { component in
      component.append(items, withAnimation: animation, completion: completion)
    }
  }

  /**
   - parameter items: A collection of view models
   - parameter componentIndex: The index of the component that you want to prepend to, defaults to 0
   - parameter controller: A SpotsController instance.
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the component has performed updates internally
   */
  public func prepend(_ items: [Item], componentIndex: Int = 0, controller: SpotsController, withAnimation animation: Animation = .none, completion: Completion = nil) {
    resolveComponent(atIndex: componentIndex, controller: controller, completion: completion) { component in
      component.prepend(items, withAnimation: animation, completion: completion)
    }
  }

  /**
   - parameter item: The view model that you want to insert
   - parameter index: The index that you want to insert the view model at
   - parameter componentIndex: The index of the component that you want to insert into
   - parameter controller: A SpotsController instance.
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the component has performed updates internally
   */
  public func insert(_ item: Item, index: Int = 0, componentIndex: Int, controller: SpotsController, withAnimation animation: Animation = .none, completion: Completion = nil) {
    resolveComponent(atIndex: componentIndex, controller: controller, completion: completion) { component in
      component.insert(item, index: index, withAnimation: animation, completion: completion)
    }
  }

  /// Update item at index inside a specific Component object
  ///
  /// - parameter item:       The view model that you want to update.
  /// - parameter index:      The index that you want to insert the view model at.
  /// - parameter componentIndex:  The index of the component that you want to update into.
  /// - parameter controller: A SpotsController instance.
  /// - parameter animation:  A Animation struct that determines which animation that should be used to perform the update.
  /// - parameter completion: A completion closure that will run after the component has performed updates internally.
  public func update(_ item: Item, index: Int = 0, componentIndex: Int, controller: SpotsController, withAnimation animation: Animation = .none, completion: Completion = nil) {
    guard let oldItem = controller.component(at: componentIndex)?.item(at: index)
      else {
        completion?()
        return
    }

    guard item != oldItem else {
      completion?()
      return
    }

    #if os(iOS)
      if animation == .none {
        CATransaction.begin()
      }
    #endif

    resolveComponent(atIndex: componentIndex, controller: controller, completion: completion) { component in
      component.update(item, index: index, withAnimation: animation) {
        completion?()
        #if os(iOS)
          if animation == .none {
            CATransaction.commit()
          }
        #endif
      }
    }
  }

  /**
   - parameter indexes: An integer array of indexes that you want to update
   - parameter componentIndex: The index of the component that you want to update into
   - parameter controller: A SpotsController instance.
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the component has performed updates internally
   */
  public func update(_ indexes: [Int], componentIndex: Int = 0, controller: SpotsController, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    resolveComponent(atIndex: componentIndex, controller: controller, completion: completion) { component in
      component.reload(indexes, withAnimation: animation, completion: completion)
    }
  }

  /**
   - parameter index: The index of the view model that you want to remove
   - parameter componentIndex: The index of the component that you want to remove into
   - parameter controller: A SpotsController instance.
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the component has performed updates internally
   */
  public func delete(_ index: Int, componentIndex: Int = 0, controller: SpotsController, withAnimation animation: Animation = .none, completion: Completion = nil) {
    resolveComponent(atIndex: componentIndex, controller: controller, completion: completion) { component in
      component.delete(index, withAnimation: animation, completion: completion)
    }
  }

  /**
   - parameter indexes: A collection of indexes for view models that you want to remove
   - parameter componentIndex: The index of the component that you want to remove into
   - parameter controller: A SpotsController instance.
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the component has performed updates internally
   */
  public func delete(_ indexes: [Int], componentIndex: Int = 0, controller: SpotsController, withAnimation animation: Animation = .none, completion: Completion = nil) {
    resolveComponent(atIndex: componentIndex, controller: controller, completion: completion) { component in
      component.delete(indexes, withAnimation: animation, completion: completion)
    }
  }

  private func resolveComponent(atIndex componentIndex: Int, controller: SpotsController, completion: Completion, closure: (Component) -> Void) {
    guard let component = controller.component(at: componentIndex) else {
      assertionFailure("Could not resolve component at index: \(componentIndex).")
      completion?()
      return
    }

    closure(component)
  }

  /// Remove all views from components view.
  ///
  /// - Parameter controller: A SpotsController instance.
  private func cleanUpComponentView(controller: SpotsController) {
    controller.scrollView.componentsView.subviews.forEach {
      $0.removeFromSuperview()
    }
  }

  /// Update `Component` with new `ComponentModel` based of changes from `Item`'s diff.
  /// This is used when reloading a `SpotsController` with a collection of `ComponentModel`'s.
  /// It is also used in `updateIfNeeded` to update with more precision, and only if it is needed.
  ///
  /// - Parameters:
  ///   - model: The new model that
  ///   - component: The component that should be updated.
  ///   - controller: The controller that the component belongs to.
  ///   - animation: The animation that should be used when performing the update.
  ///   - completion: A completion closure that will run if updates where performed.
  /// - Returns: Will return `true` if updates where performed, otherwise `false`.
  @discardableResult private func updateComponentModel(_ model: ComponentModel, on component: Component, in controller: SpotsController, withAnimation animation: Animation = .automatic, completion: Completion) -> Bool {
    let tempComponent = Component(model: model)
    tempComponent.setup(with: component.view.frame.size)
    tempComponent.model.size = CGSize(
      width: controller.view.frame.width,
      height: ceil(tempComponent.view.frame.height))

    guard let diff = Item.evaluate(tempComponent.model.items, oldModels: component.model.items) else {
      return false
    }

    let newItems = tempComponent.model.items
    let changes: (ItemChanges) = Item.processChanges(diff)

    for index in changes.updatedChildren {
      if index < tempComponent.compositeComponents.count {
        component.compositeComponents[index].component.view.removeFromSuperview()
        component.compositeComponents[index] = tempComponent.compositeComponents[index]
        component.compositeComponents[index].component.parentComponent = component
      }
    }

    if newItems.count == component.model.items.count {
      reload(with: changes,
             controller: controller,
             in: component,
             newItems: newItems,
             animation: animation,
             completion: completion)
    } else if newItems.count < component.model.items.count {
      reload(with: changes,
             controller: controller,
             in: component,
             lessItems: newItems,
             animation: animation,
             completion: completion)
    } else if newItems.count > component.model.items.count {
      reload(with: changes,
             controller: controller,
             in: component,
             moreItems: newItems,
             animation: animation,
             completion: completion)
    }

    return true
  }
}
