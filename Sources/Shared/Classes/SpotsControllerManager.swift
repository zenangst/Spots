// swiftlint:disable type_body_length
#if os(OSX)
  import Foundation
#else
  import UIKit
#endif

public class SpotsControllerManager {

  public typealias CompareClosure = ((_ lhs: [ComponentModel], _ rhs: [ComponentModel]) -> Bool)

  /**
   Reload all components.

   - parameter animated:   A boolean value that indicates if animations should be applied, defaults to true
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

      let oldSpots = controller.components
      let oldComponentModels = oldSpots.map { $0.model }
      var newComponentModels = components

      /// Prepare default layouts for new components based of previous Component kind.
      for (index, _) in newComponentModels.enumerated() {
        guard index < oldComponentModels.count else {
          break
        }

        if newComponentModels[index].layout == nil {
          newComponentModels[index].layout = type(of: oldSpots[index]).layout
        }
      }

      guard compare(newComponentModels, oldComponentModels) else {
        controller.cache()
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
          controller.cache()
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

  fileprivate func replaceComponent(atIndex index: Int, controller: SpotsController, newComponentModels: [ComponentModel], yOffset: inout CGFloat) {
    let component = Component(model: newComponentModels[index])
    let oldSpot = controller.components[index]

    /// Remove old composite components from superview and empty container
    for compositeSpot in oldSpot.compositeComponents {
      compositeSpot.component.view.removeFromSuperview()
    }
    oldSpot.compositeComponents = []

    component.view.frame = oldSpot.view.frame

    oldSpot.view.removeFromSuperview()
    controller.components[index] = component
    controller.scrollView.componentsView.insertSubview(component.view, at: index)
    controller.setupComponent(at: index, component: component)

    yOffset += component.view.frame.size.height
  }

  fileprivate func newComponent(atIndex index: Int, controller: SpotsController, newComponentModels: [ComponentModel], yOffset: inout CGFloat) {
    let component = Component(model: newComponentModels[index])
    controller.components.append(component)
    controller.setupComponent(at: index, component: component)

    yOffset += component.view.frame.size.height
  }

  /// Remove Spot at index
  ///
  /// - parameter index: The index of the Component object hat you want to remove
  fileprivate func removeComponent(atIndex index: Int, controller: SpotsController) {
    guard index < controller.components.count else {
      return
    }
    controller.components[index].view.removeFromSuperview()
  }

  /// Set up items for a Component object
  ///
  /// - parameter index:         The index of the Component object
  /// - parameter newComponentModels: A collection of new components
  /// - parameter animation:     A Animation that is used to determine which animation to use when performing the update
  /// - parameter closure:       A completion closure that is invoked when the setup of the new items is complete
  ///
  /// - returns: A boolean value that determines if the closure should run in `process(changes:)`
  fileprivate func setupItemsForComponent(atIndex index: Int, controller: SpotsController, newComponentModels: [ComponentModel], withAnimation animation: Animation = .automatic, completion: Completion = nil) -> Bool {
    guard let component = controller.component(at: index) else {
      return false
    }

    let tempSpot = Component(model: newComponentModels[index])
    tempSpot.setup(with: component.view.frame.size)
    tempSpot.model.size = CGSize(
      width: controller.view.frame.width,
      height: ceil(tempSpot.view.frame.height))

    guard let diff = Item.evaluate(tempSpot.model.items, oldModels: component.model.items) else {
      return true
    }

    let newItems = tempSpot.model.items
    let changes: (ItemChanges) = Item.processChanges(diff)

    for index in changes.updatedChildren {
      if index < tempSpot.compositeComponents.count {
        component.compositeComponents[index].component.view.removeFromSuperview()
        component.compositeComponents[index] = tempSpot.compositeComponents[index]
        component.compositeComponents[index].parentComponent = component
      }
    }

    if newItems.count == component.model.items.count {
      reload(with: changes, controller: controller, in: component, newItems: newItems, animation: animation) { [weak self] in
        if let strongSelf = self, let completion = completion {
          strongSelf.completeUpdates(controller: controller)
          completion()
        }
      }
    } else if newItems.count < component.model.items.count {
      reload(with: changes, controller: controller, in: component, lessItems: newItems, animation: animation) { [weak self] in
        if let strongSelf = self, let completion = completion {
          strongSelf.completeUpdates(controller: controller)
          completion()
        }
      }
    } else if newItems.count > component.model.items.count {
      reload(with: changes, controller: controller, in: component, moreItems: newItems, animation: animation) { [weak self] in
        if let strongSelf = self, let completion = completion {
          strongSelf.completeUpdates(controller: controller)
          completion()
        }
      }
    }

    return false
  }

  /// Reload Component object with changes and new items.
  ///
  /// - parameter changes:   A ItemChanges tuple.
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
      component.beforeUpdate()

      for item in newItems {
        let results = component.compositeComponents.filter({ $0.itemIndex == item.index })
        for compositeSpot in results {
          offsets.append(compositeSpot.component.view.contentOffset)
        }
      }

      component.model.items = newItems
    }) { [weak self] in
      guard let strongSelf = self else {
        return
      }

      for (index, item) in newItems.enumerated() {
        guard index < controller.components.count else {
          break
        }

        let compositeComponents = controller.components[item.index].compositeComponents
          .filter({ $0.itemIndex == item.index })
        for (index, compositeSpot) in compositeComponents.enumerated() {
          guard index < offsets.count else {
            continue
          }

          compositeSpot.component.view.contentOffset = offsets[index]
        }
      }

      strongSelf.finishReloading(component: component, controller: controller, withCompletion: completion)
    }
  }

  /// Reload Component object with less items
  ///
  /// - parameter changes:   A ItemChanges tuple.
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
      component.beforeUpdate()
      component.model.items = newItems
    }) { [weak self] in
      guard let strongSelf = self, !newItems.isEmpty else {
        self?.finishReloading(component: component, controller: controller, withCompletion: completion)
        return
      }

      let executeClosure = newItems.count - 1
      for (index, item) in newItems.enumerated() {
        let components = Parser.parse(item.children).map { $0.model }

        let oldSpots = controller.components.flatMap({
          $0.compositeComponents
        })

        for removedSpot in oldSpots {
          guard !components.contains(removedSpot.component.model) else {
            continue
          }

          if let index = removedSpot.parentComponent?.compositeComponents.index(of: removedSpot) {
            removedSpot.parentComponent?.compositeComponents.remove(at: index)
          }
        }

        if !component.model.items.filter({ !$0.children.isEmpty }).isEmpty {
          component.beforeUpdate()
          component.reload(nil, withAnimation: animation) {
            strongSelf.finishReloading(component: component, controller: controller, withCompletion: completion)
          }
        } else {
          component.beforeUpdate()
          component.update(item, index: index, withAnimation: animation) {
            guard index == executeClosure else {
              return
            }
            strongSelf.finishReloading(component: component, controller: controller, withCompletion: completion)
          }
        }
      }
    }
  }

  /// Reload Component object with more items
  ///
  /// - parameter changes:   A ItemChanges tuple.
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
      component.beforeUpdate()
      component.model.items = newItems
    }) {
      if !component.model.items.filter({ !$0.children.isEmpty }).isEmpty {
        component.reload(nil, withAnimation: animation) { [weak self] in
          self?.finishReloading(component: component, controller: controller, withCompletion: completion)
        }
      } else {
        component.updateHeight { [weak self] in
          self?.finishReloading(component: component, controller: controller, withCompletion: completion)
        }
      }
    }
  }

  private func finishReloading(component: Component, controller: SpotsController, withCompletion completion: Completion = nil) {
    component.afterUpdate()
    completion?()
    controller.scrollView.layoutSubviews()
  }

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

          runCompletion = strongSelf.setupItemsForComponent(atIndex: index,
                                                            controller: controller,
                                                            newComponentModels: newComponentModels,
                                                            withAnimation: animation,
                                                            completion: completion)
        case .none: continue
        }
      }

      for removedSpot in controller.components where removedSpot.view.superview == nil {
        if let index = controller.components.index(where: { removedSpot.view.isEqual($0.view) }) {
          controller.components.remove(at: index)
        }
      }

      if runCompletion {
        strongSelf.completeUpdates(controller: controller)
        finalCompletion?()
      }
    }
  }

  ///Reload if needed using JSON
  ///
  /// - parameter json: A JSON dictionary that gets parsed into UI elements
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

      let newSpots: [Component] = Parser.parse(json)
      let newComponentModels = newSpots.map { $0.model }
      let oldComponentModels = controller.components.map { $0.model }

      guard compare(newComponentModels, oldComponentModels) else {
        controller.cache()
        SpotsController.componentsDidReloadComponentModels?(controller)
        completion?()
        return
      }

      var offsets = [CGPoint]()
      let oldComposites = controller.components.flatMap { $0.compositeComponents }

      if newComponentModels.count == oldComponentModels.count {
        offsets = controller.components.map { $0.view.contentOffset }
      }

      controller.components = newSpots

      if controller.scrollView.superview == nil {
        controller.view.addSubview(controller.scrollView)
      }

      strongSelf.reloadSpotsScrollView(controller: controller)
      controller.setupComponents(animated: animated)
      controller.cache()

      let newComposites = controller.components.flatMap { $0.compositeComponents }

      for (index, compositeSpot) in oldComposites.enumerated() {
        if index == newComposites.count {
          break
        }

        newComposites[index].component.view.contentOffset = compositeSpot.component.view.contentOffset
      }

      completion?()

      offsets.enumerated().forEach {
        newSpots[$0.offset].view.contentOffset = $0.element
      }

      controller.scrollView.layoutSubviews()
      SpotsController.componentsDidReloadComponentModels?(controller)
    }
  }

  /// Reload with component models
  ///
  ///- parameter component models: A collection of component models.
  ///- parameter animated: An animation closure that can be used to perform custom animations when reloading
  ///- parameter completion: A closure that will be run after reload has been performed on all components
  public func reload(models: [ComponentModel], controller: SpotsController, animated: ((_ view: View) -> Void)? = nil, completion: Completion = nil) {
    Dispatch.main { [weak self] in
      guard let strongSelf = self else {
        completion?()
        return
      }

      controller.components = Parser.parse(models)
      controller.cache()

      if controller.scrollView.superview == nil {
        controller.view.addSubview(controller.scrollView)
      }

      let previousContentOffset = controller.scrollView.contentOffset

      strongSelf.reloadSpotsScrollView(controller: controller)
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
  ///- parameter animated: An animation closure that can be used to perform custom animations when reloading
  ///- parameter completion: A closure that will be run after reload has been performed on all components
  public func reload(json: [String : Any], controller: SpotsController, animated: ((_ view: View) -> Void)? = nil, completion: Completion = nil) {
    Dispatch.main { [weak self] in
      guard let strongSelf = self else {
        completion?()
        return
      }

      controller.components = Parser.parse(json)
      controller.cache()

      if controller.scrollView.superview == nil {
        controller.view.addSubview(controller.scrollView)
      }

      let previousContentOffset = controller.scrollView.contentOffset

      strongSelf.reloadSpotsScrollView(controller: controller)
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
   - parameter componentAtIndex: The index of the component that you want to perform updates on
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that is performed when the update is completed
   - parameter closure: A transform closure to perform the proper modification to the target component before updating the internals
   */
  public func update(componentAtIndex index: Int = 0, controller: SpotsController, withAnimation animation: Animation = .automatic, withCompletion completion: Completion = nil, _ closure: (_ component: Component) -> Void) {
    guard let component = controller.component(at: index) else {
      completion?()
      return
    }

    closure(component)
    component.refreshIndexes()
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
        component.updateHeight {
          component.afterUpdate()
          completion?()
          component.view.layoutIfNeeded()
        }
      }
    }
  }

  /**
   Updates component only if the passed view models are not the same with the current ones.

   - parameter componentAtIndex: The index of the component that you want to perform updates on
   - parameter items: An array of view models
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that is run when the update is completed
   */
  public func updateIfNeeded(componentAtIndex index: Int = 0, controller: SpotsController, items: [Item], withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    guard let component = controller.component(at: index), !(component.model.items == items) else {
      controller.scrollView.layoutSubviews()
      completion?()
      return
    }

    update(componentAtIndex: index, controller: controller, withAnimation: animation, withCompletion: {
      completion?()
    }, { component in
      component.model.items = items
    })
  }

  /**
   - parameter item: The view model that you want to append
   - parameter componentIndex: The index of the component that you want to append to, defaults to 0
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the component has performed updates internally
   */
  public func append(_ item: Item, componentIndex: Int = 0, controller: SpotsController, withAnimation animation: Animation = .none, completion: Completion = nil) {
    controller.component(at: componentIndex)?.append(item, withAnimation: animation) {
      controller.scrollView.layoutSubviews()
      completion?()
    }
    controller.component(at: componentIndex)?.refreshIndexes()
  }

  /**
   - parameter items: A collection of view models
   - parameter componentIndex: The index of the component that you want to append to, defaults to 0
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the component has performed updates internally
   */
  public func append(_ items: [Item], componentIndex: Int = 0, controller: SpotsController, withAnimation animation: Animation = .none, completion: Completion = nil) {
    controller.component(at: componentIndex)?.append(items, withAnimation: animation) {
      controller.scrollView.layoutSubviews()
      completion?()
    }
    controller.component(at: componentIndex)?.refreshIndexes()
  }

  /**
   - parameter items: A collection of view models
   - parameter componentIndex: The index of the component that you want to prepend to, defaults to 0
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the component has performed updates internally
   */
  public func prepend(_ items: [Item], componentIndex: Int = 0, controller: SpotsController, withAnimation animation: Animation = .none, completion: Completion = nil) {
    controller.component(at: componentIndex)?.prepend(items, withAnimation: animation) {
      controller.scrollView.layoutSubviews()
      completion?()
    }
    controller.component(at: componentIndex)?.refreshIndexes()
  }

  /**
   - parameter item: The view model that you want to insert
   - parameter index: The index that you want to insert the view model at
   - parameter componentIndex: The index of the component that you want to insert into
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the component has performed updates internally
   */
  public func insert(_ item: Item, index: Int = 0, componentIndex: Int, controller: SpotsController, withAnimation animation: Animation = .none, completion: Completion = nil) {
    controller.component(at: componentIndex)?.insert(item, index: index, withAnimation: animation) {
      controller.scrollView.layoutSubviews()
      completion?()
    }
    controller.component(at: componentIndex)?.refreshIndexes()
  }

  /// Update item at index inside a specific Component object
  ///
  /// - parameter item:       The view model that you want to update.
  /// - parameter index:      The index that you want to insert the view model at.
  /// - parameter componentIndex:  The index of the component that you want to update into.
  /// - parameter animation:  A Animation struct that determines which animation that should be used to perform the update.
  /// - parameter completion: A completion closure that will run after the component has performed updates internally.
  public func update(_ item: Item, index: Int = 0, componentIndex: Int, controller: SpotsController, withAnimation animation: Animation = .none, completion: Completion = nil) {
    guard let oldItem = controller.component(at: componentIndex)?.item(at: index), item != oldItem
      else {
        completion?()
        return
    }

    #if os(iOS)
      if animation == .none {
        CATransaction.begin()
      }
    #endif

    controller.component(at: componentIndex)?.update(item, index: index, withAnimation: animation) {
      controller.scrollView.layoutSubviews()
      completion?()
      #if os(iOS)
        if animation == .none {
          CATransaction.commit()
        }
      #endif
    }
  }

  /**
   - parameter indexes: An integer array of indexes that you want to update
   - parameter componentIndex: The index of the component that you want to update into
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the component has performed updates internally
   */
  public func update(_ indexes: [Int], componentIndex: Int = 0, controller: SpotsController, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    controller.component(at: componentIndex)?.reload(indexes, withAnimation: animation) {
      completion?()
    }
    controller.component(at: componentIndex)?.refreshIndexes()
  }

  /**
   - parameter index: The index of the view model that you want to remove
   - parameter componentIndex: The index of the component that you want to remove into
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the component has performed updates internally
   */
  public func delete(_ index: Int, componentIndex: Int = 0, controller: SpotsController, withAnimation animation: Animation = .none, completion: Completion = nil) {
    controller.component(at: componentIndex)?.delete(index, withAnimation: animation) {
      completion?()
    }
    controller.component(at: componentIndex)?.refreshIndexes()
  }

  /**
   - parameter indexes: A collection of indexes for view models that you want to remove
   - parameter componentIndex: The index of the component that you want to remove into
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the component has performed updates internally
   */
  public func delete(_ indexes: [Int], componentIndex: Int = 0, controller: SpotsController, withAnimation animation: Animation = .none, completion: Completion = nil) {
    controller.component(at: componentIndex)?.delete(indexes, withAnimation: animation) {
      completion?()
    }
    controller.component(at: componentIndex)?.refreshIndexes()
  }

  fileprivate func reloadSpotsScrollView(controller: SpotsController) {
    controller.scrollView.componentsView.subviews.forEach {
      $0.removeFromSuperview()
    }
  }

  fileprivate func completeUpdates(controller: SpotsController) {
    for component in controller.components {
      component.afterUpdate()
    }

    #if !os(OSX)
      controller.scrollView.layoutSubviews()
    #endif
  }
}
