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
    var spotsLeft = spots.count

    Dispatch.main { [weak self] in
      self?.spots.forEach { spot in
        spot.reload([], withAnimation: animation) {
          spotsLeft -= 1

          if spotsLeft == 0 {
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
  /// - parameter completion: A closure that will be run after reload has been performed on all spots
  public func reloadIfNeeded(_ components: [ComponentModel],
                             compare: @escaping CompareClosure = { lhs, rhs in return lhs !== rhs },
                             withAnimation animation: Animation = .automatic,
                             completion: Completion = nil) {
    guard !components.isEmpty else {
      Dispatch.main { [weak self] in
        self?.spots.forEach {
          $0.view.removeFromSuperview()
        }
        self?.spots = []
        completion?()
      }
      return
    }

    Dispatch.interactive { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      let oldSpots = weakSelf.spots
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
        weakSelf.cache()
        Dispatch.main {
          weakSelf.scrollView.layoutViews()
          if let controller = self as? Controller {
            Controller.spotsDidReloadComponentModels?(controller)
          }
          completion?()
        }
        return
      }

      let changes = weakSelf.generateChanges(from: newComponentModels, and: oldComponentModels)

      weakSelf.process(changes: changes, components: newComponentModels, withAnimation: animation) {
        Dispatch.main {
          weakSelf.scrollView.layoutSubviews()
          weakSelf.cache()
          if let controller = self as? Controller {
            Controller.spotsDidReloadComponentModels?(controller)
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
    let spot = Factory.resolve(model: newComponentModels[index])
    let oldSpot = spots[index]

    /// Remove old composite spots from superview and empty container
    for compositeSpot in oldSpot.compositeComponents {
      compositeSpot.spot.view.removeFromSuperview()
    }
    oldSpot.compositeComponents = []

    spot.view.frame = oldSpot.view.frame

    oldSpot.view.removeFromSuperview()
    spots[index] = spot
    scrollView.spotsContentView.insertSubview(spot.view, at: index)
    setupComponent(at: index, spot: spot)

    #if !os(OSX)
      (spot as? CarouselComponent)?.layout.yOffset = yOffset
    #endif
    yOffset += spot.view.frame.size.height
  }

  fileprivate func newComponent(_ index: Int, newComponentModels: [ComponentModel], yOffset: inout CGFloat) {
    let spot = Factory.resolve(model: newComponentModels[index])
    spots.append(spot)
    setupComponent(at: index, spot: spot)
    #if !os(OSX)
      (spot as? CarouselComponent)?.layout.yOffset = yOffset
    #endif
    yOffset += spot.view.frame.size.height
  }

  /// Remove Spot at index
  ///
  /// - parameter index: The index of the CoreComponent object hat you want to remove
  fileprivate func removeComponent(at index: Int) {
    guard index < spots.count else {
      return
    }
    spots[index].view.removeFromSuperview()
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
    guard let spot = self.spot(at: index, ofType: CoreComponent.self) else {
      return false
    }

    let tempSpot = Factory.resolve(model: newComponentModels[index])
    tempSpot.view.frame = spot.view.frame
    tempSpot.setup(tempSpot.view.frame.size)
    tempSpot.layout(tempSpot.view.frame.size)
    tempSpot.view.frame.size.height = tempSpot.computedHeight
    tempSpot.view.layoutIfNeeded()
    tempSpot.registerAndPrepare()

    tempSpot.model.size = CGSize(
      width: view.frame.width,
      height: ceil(tempSpot.view.frame.height))

    guard let diff = Item.evaluate(tempSpot.items, oldModels: spot.items) else {
      return true
    }

    let newItems = tempSpot.items
    let changes: (ItemChanges) = Item.processChanges(diff)

    for index in changes.updatedChildren {
      if index < tempSpot.compositeComponents.count {
        spot.compositeComponents[index].spot.view.removeFromSuperview()
        spot.compositeComponents[index] = tempSpot.compositeComponents[index]
        spot.compositeComponents[index].parentSpot = spot
      }
    }

    if newItems.count == spot.items.count {
      reload(with: changes, in: spot, newItems: newItems, animation: animation) { [weak self] in
        if let weakSelf = self, let completion = completion {
          weakSelf.setupAndLayoutSpots()
          completion()
        }
      }
    } else if newItems.count < spot.items.count {
      reload(with: changes, in: spot, lessItems: newItems, animation: animation) { [weak self] in
        if let weakSelf = self, let completion = completion {
          weakSelf.setupAndLayoutSpots()
          completion()
        }
      }
    } else if newItems.count > spot.items.count {
      reload(with: changes, in: spot, moreItems: newItems, animation: animation) { [weak self] in
        if let weakSelf = self, let completion = completion {
          weakSelf.setupAndLayoutSpots()
          completion()
        }
      }
    }

    return false
  }

  /// Reload CoreComponent object with changes and new items.
  ///
  /// - parameter changes:   A ItemChanges tuple.
  /// - parameter spot:      The spotable object that should be updated.
  /// - parameter newItems:  The new items that should be used to updated the data source.
  /// - parameter animation: The animation that should be used when updating.
  /// - parameter closure:   A completion closure.
  private func reload(with changes: (ItemChanges),
                      in spot: CoreComponent,
                      newItems: [Item],
                      animation: Animation,
                      completion: (() -> Void)? = nil) {
    var offsets = [CGPoint]()

    spot.reloadIfNeeded(changes, withAnimation: animation, updateDataSource: {
      spot.beforeUpdate()

      for item in newItems {
        let results = spot.compositeComponents.filter({ $0.itemIndex == item.index })
        for compositeSpot in results {
          offsets.append(compositeSpot.spot.view.contentOffset)
        }
      }

      spot.items = newItems
    }) { [weak self] in
      guard let weakSelf = self else {
        return
      }

      for (index, item) in newItems.enumerated() {
        guard index < weakSelf.spots.count else {
          break
        }

        let compositeComponents = weakSelf.spots[item.index].compositeComponents
          .filter({ $0.itemIndex == item.index })
        for (index, compositeSpot) in compositeComponents.enumerated() {
          guard index < offsets.count else {
            continue
          }

          compositeSpot.spot.view.contentOffset = offsets[index]
        }
      }

      self?.finishReloading(spot: spot, withCompletion: completion)
    }
  }

  /// Reload CoreComponent object with less items
  ///
  /// - parameter changes:   A ItemChanges tuple.
  /// - parameter spot:      The spotable object that should be updated.
  /// - parameter newItems:  The new items that should be used to updated the data source.
  /// - parameter animation: The animation that should be used when updating.
  /// - parameter closure:   A completion closure.
  private func reload(with changes: (ItemChanges),
                      in spot: CoreComponent,
                      lessItems newItems: [Item],
                      animation: Animation,
                      completion: (() -> Void)? = nil) {
    spot.reloadIfNeeded(changes, withAnimation: animation, updateDataSource: {
      spot.beforeUpdate()
      spot.items = newItems
    }) { [weak self] in
      guard let weakSelf = self, !newItems.isEmpty else {
        self?.finishReloading(spot: spot, withCompletion: completion)
        return
      }

      let executeClosure = newItems.count - 1
      for (index, item) in newItems.enumerated() {
        let components = Parser.parse(item.children).map { $0.model }

        let oldSpots = weakSelf.spots.flatMap({
          $0.compositeComponents
        })

        for removedSpot in oldSpots {
          guard !components.contains(removedSpot.spot.model) else {
            continue
          }

          if let index = removedSpot.parentSpot?.compositeComponents.index(of: removedSpot) {
            removedSpot.parentSpot?.compositeComponents.remove(at: index)
          }
        }

        if !spot.items.filter({ !$0.children.isEmpty }).isEmpty {
          spot.beforeUpdate()
          spot.reload(nil, withAnimation: animation) {
            weakSelf.finishReloading(spot: spot, withCompletion: completion)
          }
        } else {
          spot.beforeUpdate()
          spot.update(item, index: index, withAnimation: animation) {
            guard index == executeClosure else { return }
            weakSelf.finishReloading(spot: spot, withCompletion: completion)
          }
        }
      }
    }
  }

  /// Reload CoreComponent object with more items
  ///
  /// - parameter changes:   A ItemChanges tuple.
  /// - parameter spot:      The spotable object that should be updated.
  /// - parameter newItems:  The new items that should be used to updated the data source.
  /// - parameter animation: The animation that should be used when updating.
  /// - parameter closure:   A completion closure.
  private func reload(with changes: (ItemChanges),
                      in spot: CoreComponent,
                      moreItems newItems: [Item],
                      animation: Animation,
                      completion: (() -> Void)? = nil) {
    spot.reloadIfNeeded(changes, withAnimation: animation, updateDataSource: {
      spot.beforeUpdate()
      spot.items = newItems
    }) {
      if !spot.items.filter({ !$0.children.isEmpty }).isEmpty {
        spot.reload(nil, withAnimation: animation) { [weak self] in
          self?.finishReloading(spot: spot, withCompletion: completion)
        }
      } else {
        spot.updateHeight { [weak self] in
          self?.finishReloading(spot: spot, withCompletion: completion)
        }
      }
    }
  }

  private func finishReloading(spot: CoreComponent, withCompletion completion: Completion = nil) {
    spot.afterUpdate()
    completion?()
    scrollView.layoutSubviews()
  }

  func process(changes: [ComponentModelDiff],
               components newComponentModels: [ComponentModel],
               withAnimation animation: Animation = .automatic,
               completion: Completion = nil) {
    Dispatch.main { [weak self] in
      guard let weakSelf = self else {
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
          weakSelf.replaceComponent(index, newComponentModels: newComponentModels, yOffset: &yOffset)
        case .new:
          weakSelf.newComponent(index, newComponentModels: newComponentModels, yOffset: &yOffset)
        case .removed:
          weakSelf.removeComponent(at: index)
        case .items:
          if index == lastItemChange {
            completion = finalCompletion
          }

          runCompletion = weakSelf.setupItemsForComponent(at: index,
                                                     newComponentModels: newComponentModels,
                                                     withAnimation: animation,
                                                     completion: completion)
        case .none: continue
        }
      }

      for removedSpot in weakSelf.spots where removedSpot.view.superview == nil {
        if let index = weakSelf.spots.index(where: { removedSpot.view.isEqual($0.view) }) {
          weakSelf.spots.remove(at: index)
        }
      }

      if runCompletion {
        weakSelf.setupAndLayoutSpots()
        finalCompletion?()
      }
    }
  }

  ///Reload if needed using JSON
  ///
  /// - parameter json: A JSON dictionary that gets parsed into UI elements
  /// - parameter compare: A closure that is used for comparing a ComponentModel collections
  /// - parameter animated: An animation closure that can be used to perform custom animations when reloading
  /// - parameter completion: A closure that will be run after reload has been performed on all spots
  public func reloadIfNeeded(_ json: [String : Any],
                             compare: @escaping CompareClosure = { lhs, rhs in return lhs !== rhs },
                             animated: ((_ view: View) -> Void)? = nil,
                             completion: Completion = nil) {
    Dispatch.main { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      let newSpots: [CoreComponent] = Parser.parse(json)
      let newComponentModels = newSpots.map { $0.model }
      let oldComponentModels = weakSelf.spots.map { $0.model }

      guard compare(newComponentModels, oldComponentModels) else {
        if let controller = self as? Controller {
          Controller.spotsDidReloadComponentModels?(controller)
        }
        weakSelf.cache()
        completion?()
        return
      }

      var offsets = [CGPoint]()
      let oldComposites = weakSelf.spots.flatMap { $0.compositeComponents }

      if newComponentModels.count == oldComponentModels.count {
        offsets = weakSelf.spots.map { $0.view.contentOffset }
      }

      weakSelf.spots = newSpots

      if weakSelf.scrollView.superview == nil {
        weakSelf.view.addSubview(weakSelf.scrollView)
      }

      weakSelf.reloadSpotsScrollView()
      weakSelf.setupSpots(animated: animated)
      weakSelf.cache()

      let newComposites = weakSelf.spots.flatMap { $0.compositeComponents }

      for (index, compositeSpot) in oldComposites.enumerated() {
        if index == newComposites.count {
          break
        }

        newComposites[index].spot.view.contentOffset = compositeSpot.spot.view.contentOffset
      }

      completion?()

      offsets.enumerated().forEach {
        newSpots[$0.offset].view.contentOffset = $0.element
      }

      if let controller = self as? Controller {
        Controller.spotsDidReloadComponentModels?(controller)
      }

      weakSelf.scrollView.layoutSubviews()
    }
  }

  /// Reload with JSON
  ///
  ///- parameter json: A JSON dictionary that gets parsed into UI elements
  ///- parameter animated: An animation closure that can be used to perform custom animations when reloading
  ///- parameter completion: A closure that will be run after reload has been performed on all spots
  public func reload(_ json: [String : Any], animated: ((_ view: View) -> Void)? = nil, completion: Completion = nil) {
    Dispatch.main { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      weakSelf.spots = Parser.parse(json)
      weakSelf.cache()

      if weakSelf.scrollView.superview == nil {
        weakSelf.view.addSubview(weakSelf.scrollView)
      }

      weakSelf.reloadSpotsScrollView()
      weakSelf.setupSpots(animated: animated)

      completion?()
      if let controller = weakSelf as? Controller {
        Controller.spotsDidReloadComponentModels?(controller)
      }
      weakSelf.scrollView.layoutSubviews()
    }
  }

  /**
   - parameter spotAtIndex: The index of the spot that you want to perform updates on
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that is performed when the update is completed
   - parameter closure: A transform closure to perform the proper modification to the target spot before updating the internals
   */
  public func update(spotAtIndex index: Int = 0, withAnimation animation: Animation = .automatic, withCompletion completion: Completion = nil, _ closure: (_ spot: CoreComponent) -> Void) {
    guard let spot = spot(at: index, ofType: CoreComponent.self) else {
      completion?()
      return }
    closure(spot)
    spot.refreshIndexes()
    spot.prepareItems()

    Dispatch.main { [weak self] in
      guard let weakSelf = self else { return }

      #if !os(OSX)
        if animation != .none {
          let isScrolling = weakSelf.scrollView.isDragging == true || weakSelf.scrollView.isTracking == true
          if let superview = spot.view.superview, !isScrolling {
            spot.view.frame.size.height = superview.frame.height
          }
        }
      #endif

      spot.reload(nil, withAnimation: animation) {
        spot.updateHeight {
          spot.afterUpdate()
          completion?()
          spot.view.layoutIfNeeded()
        }
      }
    }
  }

  /**
   Updates spot only if the passed view models are not the same with the current ones.

   - parameter spotAtIndex: The index of the spot that you want to perform updates on
   - parameter items: An array of view models
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that is run when the update is completed
   */
  public func updateIfNeeded(spotAtIndex index: Int = 0, items: [Item], withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    guard let spot = spot(at: index, ofType: CoreComponent.self), !(spot.items == items) else {
      scrollView.layoutSubviews()
      completion?()
      return
    }

    update(spotAtIndex: index, withAnimation: animation, withCompletion: {
      completion?()
    }, {
      $0.items = items
    })
  }

  /**
   - parameter item: The view model that you want to append
   - parameter spotIndex: The index of the spot that you want to append to, defaults to 0
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the spot has performed updates internally
   */
  public func append(_ item: Item, spotIndex: Int = 0, withAnimation animation: Animation = .none, completion: Completion = nil) {
    spot(at: spotIndex, ofType: CoreComponent.self)?.append(item, withAnimation: animation) { [weak self] in
      completion?()
      self?.scrollView.layoutSubviews()
    }
    spot(at: spotIndex, ofType: CoreComponent.self)?.refreshIndexes()
  }

  /**
   - parameter items: A collection of view models
   - parameter spotIndex: The index of the spot that you want to append to, defaults to 0
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the spot has performed updates internally
   */
  public func append(_ items: [Item], spotIndex: Int = 0, withAnimation animation: Animation = .none, completion: Completion = nil) {
    spot(at: spotIndex, ofType: CoreComponent.self)?.append(items, withAnimation: animation) { [weak self] in
      completion?()
      self?.scrollView.layoutSubviews()
    }
    spot(at: spotIndex, ofType: CoreComponent.self)?.refreshIndexes()
  }

  /**
   - parameter items: A collection of view models
   - parameter spotIndex: The index of the spot that you want to prepend to, defaults to 0
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the spot has performed updates internally
   */
  public func prepend(_ items: [Item], spotIndex: Int = 0, withAnimation animation: Animation = .none, completion: Completion = nil) {
    spot(at: spotIndex, ofType: CoreComponent.self)?.prepend(items, withAnimation: animation) { [weak self] in
      completion?()
      self?.scrollView.layoutSubviews()
    }
    spot(at: spotIndex, ofType: CoreComponent.self)?.refreshIndexes()
  }

  /**
   - parameter item: The view model that you want to insert
   - parameter index: The index that you want to insert the view model at
   - parameter spotIndex: The index of the spot that you want to insert into
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the spot has performed updates internally
   */
  public func insert(_ item: Item, index: Int = 0, spotIndex: Int, withAnimation animation: Animation = .none, completion: Completion = nil) {
    spot(at: spotIndex, ofType: CoreComponent.self)?.insert(item, index: index, withAnimation: animation) { [weak self] in
      completion?()
      self?.scrollView.layoutSubviews()
    }
    spot(at: spotIndex, ofType: CoreComponent.self)?.refreshIndexes()
  }

  /// Update item at index inside a specific CoreComponent object
  ///
  /// - parameter item:       The view model that you want to update.
  /// - parameter index:      The index that you want to insert the view model at.
  /// - parameter spotIndex:  The index of the spot that you want to update into.
  /// - parameter animation:  A Animation struct that determines which animation that should be used to perform the update.
  /// - parameter completion: A completion closure that will run after the spot has performed updates internally.
  public func update(_ item: Item, index: Int = 0, spotIndex: Int, withAnimation animation: Animation = .none, completion: Completion = nil) {
    guard let oldItem = spot(at: spotIndex, ofType: CoreComponent.self)?.item(at: index), item != oldItem
      else {
        completion?()
        return
    }

    #if os(iOS)
      if animation == .none {
        CATransaction.begin()
      }
    #endif

    spot(at: spotIndex, ofType: CoreComponent.self)?.update(item, index: index, withAnimation: animation) { [weak self] in
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
   - parameter spotIndex: The index of the spot that you want to update into
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the spot has performed updates internally
   */
  public func update(_ indexes: [Int], spotIndex: Int = 0, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    spot(at: spotIndex, ofType: CoreComponent.self)?.reload(indexes, withAnimation: animation) {
      completion?()
    }
    spot(at: spotIndex, ofType: CoreComponent.self)?.refreshIndexes()
  }

  /**
   - parameter index: The index of the view model that you want to remove
   - parameter spotIndex: The index of the spot that you want to remove into
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the spot has performed updates internally
   */
  public func delete(_ index: Int, spotIndex: Int = 0, withAnimation animation: Animation = .none, completion: Completion = nil) {
    spot(at: spotIndex, ofType: CoreComponent.self)?.delete(index, withAnimation: animation) {
      completion?()
    }
    spot(at: spotIndex, ofType: CoreComponent.self)?.refreshIndexes()
  }

  /**
   - parameter indexes: A collection of indexes for view models that you want to remove
   - parameter spotIndex: The index of the spot that you want to remove into
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the spot has performed updates internally
   */
  public func delete(_ indexes: [Int], spotIndex: Int = 0, withAnimation animation: Animation = .none, completion: Completion = nil) {
    spot(at: spotIndex, ofType: CoreComponent.self)?.delete(indexes, withAnimation: animation) {
      completion?()
    }
    spot(at: spotIndex, ofType: CoreComponent.self)?.refreshIndexes()
  }

  #if os(iOS)
  public func refreshSpots(_ refreshControl: UIRefreshControl) {
    Dispatch.main { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.refreshPositions.removeAll()

      weakSelf.refreshDelegate?.spotablesDidReload(weakSelf.spots, refreshControl: refreshControl) {
        refreshControl.endRefreshing()
      }
    }
  }
  #endif

  fileprivate func reloadSpotsScrollView() {
    scrollView.spotsContentView.subviews.forEach {
      $0.removeFromSuperview()
    }
  }

  func setupAndLayoutComponent(spot: CoreComponent) {

    switch spot {
    case let spot as Gridable:
      #if !os(OSX)
        guard spot.layout.scrollDirection == .horizontal else {
          fallthrough
        }
      #endif

      spot.layout.prepare()
      spot.layout.invalidateLayout()
      spot.collectionView.frame.size.width = spot.layout.collectionViewContentSize.width
      spot.collectionView.frame.size.height = spot.layout.collectionViewContentSize.height
    default:
      spot.setup(scrollView.frame.size)
      spot.model.size = CGSize(
        width: spot.view.frame.size.width,
        height: ceil(spot.view.frame.size.height))
      spot.layout(scrollView.frame.size)
      spot.view.layoutSubviews()
    }
  }

  fileprivate func setupAndLayoutSpots() {
    for spot in spots {
      setupAndLayoutComponent(spot: spot)
    }

    #if !os(OSX)
      scrollView.layoutSubviews()
    #endif
  }
}
