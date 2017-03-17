#if os(OSX)
  import Foundation
#else
  import UIKit
#endif

extension SpotsProtocol {

  public typealias CompareClosure = ((_ lhs: [ComponentModel], _ rhs: [ComponentModel]) -> Bool)

  /**
   Reload all CoreComponent objects

   - parameter animated:   A boolean value that indicates if animations should be applied, defaults to true
   - parameter animation:  A CoreComponentAnimation struct that determines which animation that should be used for the updates
   - parameter completion: A completion block that is run when the reloading is done
   */
  public func reload(_ animated: Bool = true, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    var componentsLeft = components.count

    Dispatch.main { [weak self] in
      self?.components.forEach { component in
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
  public func reloadIfNeeded(_ components: [ComponentModel],
                             compare: @escaping CompareClosure = { lhs, rhs in return lhs !== rhs },
                             withAnimation animation: Animation = .automatic,
                             completion: Completion = nil) {
    guard !components.isEmpty else {
      Dispatch.main { [weak self] in
        self?.components.forEach {
          $0.view.removeFromSuperview()
        }
        self?.components = []
        completion?()
      }
      return
    }

    Dispatch.interactive { [weak self] in
      guard let strongSelf = self else {
        completion?()
        return
      }

      let oldSpots = strongSelf.components
      let oldComponentModels = oldSpots.map { $0.model }
      var newComponentModels = components

      /// Prepare default layouts for new components based of previous CoreComponent kind.
      for (index, _) in newComponentModels.enumerated() {
        guard index < oldComponentModels.count else {
          break
        }

        if newComponentModels[index].layout == nil {
          newComponentModels[index].layout = type(of: oldSpots[index]).layout
        }
      }

      guard compare(newComponentModels, oldComponentModels) else {
        strongSelf.cache()
        Dispatch.main {
          strongSelf.scrollView.layoutViews()
          if let controller = self as? Controller {
            Controller.componentsDidReloadComponentModels?(controller)
          }
          completion?()
        }
        return
      }

      let changes = strongSelf.generateChanges(from: newComponentModels, and: oldComponentModels)

      strongSelf.process(changes: changes, components: newComponentModels, withAnimation: animation) {
        Dispatch.main {
          strongSelf.scrollView.layoutSubviews()
          strongSelf.cache()
          if let controller = self as? Controller {
            Controller.componentsDidReloadComponentModels?(controller)
          }

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

  fileprivate func replaceComponent(_ index: Int, newComponentModels: [ComponentModel], yOffset: inout CGFloat) {
    let component = Factory.resolve(model: newComponentModels[index])
    let oldSpot = components[index]

    /// Remove old composite components from superview and empty container
    for compositeSpot in oldSpot.compositeComponents {
      compositeSpot.component.view.removeFromSuperview()
    }
    oldSpot.compositeComponents = []

    component.view.frame = oldSpot.view.frame

    oldSpot.view.removeFromSuperview()
    components[index] = component
    scrollView.componentsView.insertSubview(component.view, at: index)
    setupComponent(at: index, component: component)

    yOffset += component.view.frame.size.height
  }

  fileprivate func newComponent(_ index: Int, newComponentModels: [ComponentModel], yOffset: inout CGFloat) {
    let component = Factory.resolve(model: newComponentModels[index])
    components.append(component)
    setupComponent(at: index, component: component)

    yOffset += component.view.frame.size.height
  }

  /// Remove Spot at index
  ///
  /// - parameter index: The index of the CoreComponent object hat you want to remove
  fileprivate func removeComponent(at index: Int) {
    guard index < components.count else {
      return
    }
    components[index].view.removeFromSuperview()
  }

  /// Set up items for a CoreComponent object
  ///
  /// - parameter index:         The index of the CoreComponent object
  /// - parameter newComponentModels: A collection of new components
  /// - parameter animation:     A Animation that is used to determine which animation to use when performing the update
  /// - parameter closure:       A completion closure that is invoked when the setup of the new items is complete
  ///
  /// - returns: A boolean value that determines if the closure should run in `process(changes:)`
  fileprivate func setupItemsForComponent(at index: Int, newComponentModels: [ComponentModel], withAnimation animation: Animation = .automatic, completion: Completion = nil) -> Bool {
    guard let component = self.component(at: index, ofType: CoreComponent.self) else {
      return false
    }

    let tempSpot = Factory.resolve(model: newComponentModels[index])
    tempSpot.view.frame = component.view.frame
    tempSpot.setup(tempSpot.view.frame.size)
    tempSpot.layout(tempSpot.view.frame.size)
    tempSpot.view.frame.size.height = tempSpot.computedHeight
    tempSpot.view.layoutIfNeeded()
    tempSpot.registerAndPrepare()

    tempSpot.model.size = CGSize(
      width: view.frame.width,
      height: ceil(tempSpot.view.frame.height))

    guard let diff = Item.evaluate(tempSpot.items, oldModels: component.items) else {
      return true
    }

    let newItems = tempSpot.items
    let changes: (ItemChanges) = Item.processChanges(diff)

    for index in changes.updatedChildren {
      if index < tempSpot.compositeComponents.count {
        component.compositeComponents[index].component.view.removeFromSuperview()
        component.compositeComponents[index] = tempSpot.compositeComponents[index]
        component.compositeComponents[index].parentComponent = component
      }
    }

    if newItems.count == component.items.count {
      reload(with: changes, in: component, newItems: newItems, animation: animation) { [weak self] in
        if let strongSelf = self, let completion = completion {
          strongSelf.setupAndLayoutSpots()
          completion()
        }
      }
    } else if newItems.count < component.items.count {
      reload(with: changes, in: component, lessItems: newItems, animation: animation) { [weak self] in
        if let strongSelf = self, let completion = completion {
          strongSelf.setupAndLayoutSpots()
          completion()
        }
      }
    } else if newItems.count > component.items.count {
      reload(with: changes, in: component, moreItems: newItems, animation: animation) { [weak self] in
        if let strongSelf = self, let completion = completion {
          strongSelf.setupAndLayoutSpots()
          completion()
        }
      }
    }

    return false
  }

  /// Reload CoreComponent object with changes and new items.
  ///
  /// - parameter changes:   A ItemChanges tuple.
  /// - parameter component:      The component that should be updated.
  /// - parameter newItems:  The new items that should be used to updated the data source.
  /// - parameter animation: The animation that should be used when updating.
  /// - parameter closure:   A completion closure.
  private func reload(with changes: (ItemChanges),
                      in component: CoreComponent,
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

      component.items = newItems
    }) { [weak self] in
      guard let strongSelf = self else {
        return
      }

      for (index, item) in newItems.enumerated() {
        guard index < strongSelf.components.count else {
          break
        }

        let compositeComponents = strongSelf.components[item.index].compositeComponents
          .filter({ $0.itemIndex == item.index })
        for (index, compositeSpot) in compositeComponents.enumerated() {
          guard index < offsets.count else {
            continue
          }

          compositeSpot.component.view.contentOffset = offsets[index]
        }
      }

      self?.finishReloading(component: component, withCompletion: completion)
    }
  }

  /// Reload CoreComponent object with less items
  ///
  /// - parameter changes:   A ItemChanges tuple.
  /// - parameter component:      The component that should be updated.
  /// - parameter newItems:  The new items that should be used to updated the data source.
  /// - parameter animation: The animation that should be used when updating.
  /// - parameter closure:   A completion closure.
  private func reload(with changes: (ItemChanges),
                      in component: CoreComponent,
                      lessItems newItems: [Item],
                      animation: Animation,
                      completion: (() -> Void)? = nil) {
    component.reloadIfNeeded(changes, withAnimation: animation, updateDataSource: {
      component.beforeUpdate()
      component.items = newItems
    }) { [weak self] in
      guard let strongSelf = self, !newItems.isEmpty else {
        self?.finishReloading(component: component, withCompletion: completion)
        return
      }

      let executeClosure = newItems.count - 1
      for (index, item) in newItems.enumerated() {
        let components = Parser.parse(item.children).map { $0.model }

        let oldSpots = strongSelf.components.flatMap({
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

        if !component.items.filter({ !$0.children.isEmpty }).isEmpty {
          component.beforeUpdate()
          component.reload(nil, withAnimation: animation) {
            strongSelf.finishReloading(component: component, withCompletion: completion)
          }
        } else {
          component.beforeUpdate()
          component.update(item, index: index, withAnimation: animation) {
            guard index == executeClosure else { return }
            strongSelf.finishReloading(component: component, withCompletion: completion)
          }
        }
      }
    }
  }

  /// Reload CoreComponent object with more items
  ///
  /// - parameter changes:   A ItemChanges tuple.
  /// - parameter component:      The component that should be updated.
  /// - parameter newItems:  The new items that should be used to updated the data source.
  /// - parameter animation: The animation that should be used when updating.
  /// - parameter closure:   A completion closure.
  private func reload(with changes: (ItemChanges),
                      in component: CoreComponent,
                      moreItems newItems: [Item],
                      animation: Animation,
                      completion: (() -> Void)? = nil) {
    component.reloadIfNeeded(changes, withAnimation: animation, updateDataSource: {
      component.beforeUpdate()
      component.items = newItems
    }) {
      if !component.items.filter({ !$0.children.isEmpty }).isEmpty {
        component.reload(nil, withAnimation: animation) { [weak self] in
          self?.finishReloading(component: component, withCompletion: completion)
        }
      } else {
        component.updateHeight { [weak self] in
          self?.finishReloading(component: component, withCompletion: completion)
        }
      }
    }
  }

  private func finishReloading(component: CoreComponent, withCompletion completion: Completion = nil) {
    component.afterUpdate()
    completion?()
    scrollView.layoutSubviews()
  }

  func process(changes: [ComponentModelDiff],
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
        case .identifier, .title, .kind, .layout, .header, .footer, .meta:
          strongSelf.replaceComponent(index, newComponentModels: newComponentModels, yOffset: &yOffset)
        case .new:
          strongSelf.newComponent(index, newComponentModels: newComponentModels, yOffset: &yOffset)
        case .removed:
          strongSelf.removeComponent(at: index)
        case .items:
          if index == lastItemChange {
            completion = finalCompletion
          }

          runCompletion = strongSelf.setupItemsForComponent(at: index,
                                                     newComponentModels: newComponentModels,
                                                     withAnimation: animation,
                                                     completion: completion)
        case .none: continue
        }
      }

      for removedSpot in strongSelf.components where removedSpot.view.superview == nil {
        if let index = strongSelf.components.index(where: { removedSpot.view.isEqual($0.view) }) {
          strongSelf.components.remove(at: index)
        }
      }

      if runCompletion {
        strongSelf.setupAndLayoutSpots()
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
                             compare: @escaping CompareClosure = { lhs, rhs in return lhs !== rhs },
                             animated: ((_ view: View) -> Void)? = nil,
                             completion: Completion = nil) {
    Dispatch.main { [weak self] in
      guard let strongSelf = self else {
        completion?()
        return
      }

      let newSpots: [CoreComponent] = Parser.parse(json)
      let newComponentModels = newSpots.map { $0.model }
      let oldComponentModels = strongSelf.components.map { $0.model }

      guard compare(newComponentModels, oldComponentModels) else {
        if let controller = self as? Controller {
          Controller.componentsDidReloadComponentModels?(controller)
        }
        strongSelf.cache()
        completion?()
        return
      }

      var offsets = [CGPoint]()
      let oldComposites = strongSelf.components.flatMap { $0.compositeComponents }

      if newComponentModels.count == oldComponentModels.count {
        offsets = strongSelf.components.map { $0.view.contentOffset }
      }

      strongSelf.components = newSpots

      if strongSelf.scrollView.superview == nil {
        strongSelf.view.addSubview(strongSelf.scrollView)
      }

      strongSelf.reloadSpotsScrollView()
      strongSelf.setupComponents(animated: animated)
      strongSelf.cache()

      let newComposites = strongSelf.components.flatMap { $0.compositeComponents }

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

      if let controller = self as? Controller {
        Controller.componentsDidReloadComponentModels?(controller)
      }

      strongSelf.scrollView.layoutSubviews()
    }
  }

  /// Reload with JSON
  ///
  ///- parameter json: A JSON dictionary that gets parsed into UI elements
  ///- parameter animated: An animation closure that can be used to perform custom animations when reloading
  ///- parameter completion: A closure that will be run after reload has been performed on all components
  public func reload(_ json: [String : Any], animated: ((_ view: View) -> Void)? = nil, completion: Completion = nil) {
    Dispatch.main { [weak self] in
      guard let strongSelf = self else {
        completion?()
        return
      }

      strongSelf.components = Parser.parse(json)
      strongSelf.cache()

      if strongSelf.scrollView.superview == nil {
        strongSelf.view.addSubview(strongSelf.scrollView)
      }

      strongSelf.reloadSpotsScrollView()
      strongSelf.setupComponents(animated: animated)

      completion?()
      if let controller = strongSelf as? Controller {
        Controller.componentsDidReloadComponentModels?(controller)
      }
      strongSelf.scrollView.layoutSubviews()
    }
  }

  /**
   - parameter componentAtIndex: The index of the component that you want to perform updates on
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that is performed when the update is completed
   - parameter closure: A transform closure to perform the proper modification to the target component before updating the internals
   */
  public func update(componentAtIndex index: Int = 0, withAnimation animation: Animation = .automatic, withCompletion completion: Completion = nil, _ closure: (_ component: CoreComponent) -> Void) {
    guard let component = component(at: index, ofType: CoreComponent.self) else {
      completion?()
      return
    }

    closure(component)
    component.refreshIndexes()
    component.prepareItems()

    Dispatch.main { [weak self] in
      guard let strongSelf = self else { return }

      #if !os(OSX)
        if animation != .none {
          let isScrolling = strongSelf.scrollView.isDragging == true || strongSelf.scrollView.isTracking == true
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
  public func updateIfNeeded(componentAtIndex index: Int = 0, items: [Item], withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    guard let component = component(at: index, ofType: CoreComponent.self), !(component.items == items) else {
      scrollView.layoutSubviews()
      completion?()
      return
    }

    update(componentAtIndex: index, withAnimation: animation, withCompletion: {
      completion?()
    }, {
      $0.items = items
    })
  }

  /**
   - parameter item: The view model that you want to append
   - parameter componentIndex: The index of the component that you want to append to, defaults to 0
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the component has performed updates internally
   */
  public func append(_ item: Item, componentIndex: Int = 0, withAnimation animation: Animation = .none, completion: Completion = nil) {
    component(at: componentIndex, ofType: CoreComponent.self)?.append(item, withAnimation: animation) { [weak self] in
      completion?()
      self?.scrollView.layoutSubviews()
    }
    component(at: componentIndex, ofType: CoreComponent.self)?.refreshIndexes()
  }

  /**
   - parameter items: A collection of view models
   - parameter componentIndex: The index of the component that you want to append to, defaults to 0
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the component has performed updates internally
   */
  public func append(_ items: [Item], componentIndex: Int = 0, withAnimation animation: Animation = .none, completion: Completion = nil) {
    component(at: componentIndex, ofType: CoreComponent.self)?.append(items, withAnimation: animation) { [weak self] in
      completion?()
      self?.scrollView.layoutSubviews()
    }
    component(at: componentIndex, ofType: CoreComponent.self)?.refreshIndexes()
  }

  /**
   - parameter items: A collection of view models
   - parameter componentIndex: The index of the component that you want to prepend to, defaults to 0
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the component has performed updates internally
   */
  public func prepend(_ items: [Item], componentIndex: Int = 0, withAnimation animation: Animation = .none, completion: Completion = nil) {
    component(at: componentIndex, ofType: CoreComponent.self)?.prepend(items, withAnimation: animation) { [weak self] in
      completion?()
      self?.scrollView.layoutSubviews()
    }
    component(at: componentIndex, ofType: CoreComponent.self)?.refreshIndexes()
  }

  /**
   - parameter item: The view model that you want to insert
   - parameter index: The index that you want to insert the view model at
   - parameter componentIndex: The index of the component that you want to insert into
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the component has performed updates internally
   */
  public func insert(_ item: Item, index: Int = 0, componentIndex: Int, withAnimation animation: Animation = .none, completion: Completion = nil) {
    component(at: componentIndex, ofType: CoreComponent.self)?.insert(item, index: index, withAnimation: animation) { [weak self] in
      completion?()
      self?.scrollView.layoutSubviews()
    }
    component(at: componentIndex, ofType: CoreComponent.self)?.refreshIndexes()
  }

  /// Update item at index inside a specific CoreComponent object
  ///
  /// - parameter item:       The view model that you want to update.
  /// - parameter index:      The index that you want to insert the view model at.
  /// - parameter componentIndex:  The index of the component that you want to update into.
  /// - parameter animation:  A Animation struct that determines which animation that should be used to perform the update.
  /// - parameter completion: A completion closure that will run after the component has performed updates internally.
  public func update(_ item: Item, index: Int = 0, componentIndex: Int, withAnimation animation: Animation = .none, completion: Completion = nil) {
    guard let oldItem = component(at: componentIndex, ofType: CoreComponent.self)?.item(at: index), item != oldItem
      else {
        completion?()
        return
    }

    #if os(iOS)
      if animation == .none {
        CATransaction.begin()
      }
    #endif

    component(at: componentIndex, ofType: CoreComponent.self)?.update(item, index: index, withAnimation: animation) { [weak self] in
      completion?()
      self?.scrollView.layoutSubviews()
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
  public func update(_ indexes: [Int], componentIndex: Int = 0, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    component(at: componentIndex, ofType: CoreComponent.self)?.reload(indexes, withAnimation: animation) {
      completion?()
    }
    component(at: componentIndex, ofType: CoreComponent.self)?.refreshIndexes()
  }

  /**
   - parameter index: The index of the view model that you want to remove
   - parameter componentIndex: The index of the component that you want to remove into
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the component has performed updates internally
   */
  public func delete(_ index: Int, componentIndex: Int = 0, withAnimation animation: Animation = .none, completion: Completion = nil) {
    component(at: componentIndex, ofType: CoreComponent.self)?.delete(index, withAnimation: animation) {
      completion?()
    }
    component(at: componentIndex, ofType: CoreComponent.self)?.refreshIndexes()
  }

  /**
   - parameter indexes: A collection of indexes for view models that you want to remove
   - parameter componentIndex: The index of the component that you want to remove into
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the component has performed updates internally
   */
  public func delete(_ indexes: [Int], componentIndex: Int = 0, withAnimation animation: Animation = .none, completion: Completion = nil) {
    component(at: componentIndex, ofType: CoreComponent.self)?.delete(indexes, withAnimation: animation) {
      completion?()
    }
    component(at: componentIndex, ofType: CoreComponent.self)?.refreshIndexes()
  }

  #if os(iOS)
  public func refreshSpots(_ refreshControl: UIRefreshControl) {
    Dispatch.main { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.refreshPositions.removeAll()

      strongSelf.refreshDelegate?.componentsDidReload(strongSelf.components, refreshControl: refreshControl) {
        refreshControl.endRefreshing()
      }
    }
  }
  #endif

  fileprivate func reloadSpotsScrollView() {
    scrollView.componentsView.subviews.forEach {
      $0.removeFromSuperview()
    }
  }

  func setupAndLayoutComponent(component: CoreComponent) {
    switch component {
    case let component as Gridable:
      #if !os(OSX)
        guard component.layout.scrollDirection == .horizontal else {
          fallthrough
        }
      #endif

      component.layout.prepare()
      component.layout.invalidateLayout()
      component.collectionView.frame.size.width = component.layout.collectionViewContentSize.width
      component.collectionView.frame.size.height = component.layout.collectionViewContentSize.height
    default:
      component.setup(scrollView.frame.size)
      component.model.size = CGSize(
        width: component.view.frame.size.width,
        height: ceil(component.view.frame.size.height))
      component.layout(scrollView.frame.size)
      component.view.layoutSubviews()
    }
  }

  fileprivate func setupAndLayoutSpots() {
    for component in components {
      setupAndLayoutComponent(component: component)
    }

    #if !os(OSX)
      scrollView.layoutSubviews()
    #endif
  }
}
