#if os(OSX)
  import Foundation
#else
  import UIKit
#endif

import Brick

extension SpotsProtocol {

  public typealias CompareClosure = ((_ lhs: [Component], _ rhs: [Component]) -> Bool)

  /**
   Reload all Spotable objects

   - parameter animated:   A boolean value that indicates if animations should be applied, defaults to true
   - parameter animation:  A SpotableAnimation struct that determines which animation that should be used for the updates
   - parameter completion: A completion block that is run when the reloading is done
   */
  public func reload(_ animated: Bool = true, withAnimation animation: Animation = .automatic, completion: Completion = nil) {
    var spotsLeft = spots.count

    Dispatch.mainQueue { [weak self] in
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
  /// - parameter compare: A closure that is used for comparing a Component collections
  /// - parameter animated: An animation closure that can be used to perform custom animations when reloading
  /// - parameter completion: A closure that will be run after reload has been performed on all spots
  public func reloadIfNeeded(_ components: [Component],
                             compare: @escaping CompareClosure = { lhs, rhs in return lhs !== rhs },
                             withAnimation animation: Animation = .automatic,
                             completion: Completion = nil) {
    guard !components.isEmpty else {
      Dispatch.mainQueue { [weak self] in
        self?.spots.forEach {
          $0.render().removeFromSuperview()
        }
        self?.spots = []
        completion?()
      }
      return
    }

    Dispatch.inQueue(queue: .interactive) { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      let oldComponents = weakSelf.spots.map { $0.component }
      let newComponents = components

      guard compare(newComponents, oldComponents) else {
        weakSelf.cache()
        Dispatch.mainQueue {
          completion?()
        }
        return
      }

      let changes = weakSelf.generateChanges(from: newComponents, and: oldComponents)

      weakSelf.process(changes: changes, components: newComponents, withAnimation: animation) {
        Dispatch.mainQueue {
          weakSelf.cache()
          if let controller = self as? Controller {
            Controller.spotsDidReloadComponents?(controller)
          }
          completion?()
          weakSelf.scrollView.layoutSubviews()
        }
      }
    }
  }

  /// Generate a change set by comparing two component collections
  ///
  /// - parameter components:    A collection of components
  /// - parameter oldComponents: A collection of components
  ///
  /// - returns: A ComponentDiff struct
  func generateChanges(from components: [Component], and oldComponents: [Component]) -> [ComponentDiff] {
    let oldComponentCount = oldComponents.count
    var changes = [ComponentDiff]()
    for (index, component) in components.enumerated() {
      if index >= oldComponentCount {
        changes.append(.new)
        continue
      }

      changes.append(component.diff(component: oldComponents[index]))
    }

    if oldComponentCount > components.count {
      oldComponents[components.count..<oldComponents.count].forEach { _ in
        changes.append(.removed)
      }
    }

    return changes
  }

  fileprivate func replaceSpot(_ index: Int, newComponents: [Component], yOffset: inout CGFloat) {
    let spot = Factory.resolve(component: newComponents[index])
    let oldSpot = spots[index]

    /// Remove old composite spots from superview and empty container
    for compositeSpot in oldSpot.compositeSpots {
      compositeSpot.spot.render().removeFromSuperview()
    }
    oldSpot.compositeSpots = []

    spot.render().frame = oldSpot.render().frame

    oldSpot.render().removeFromSuperview()
    spots[index] = spot
    #if os(OSX)
      scrollView.spotsContentView.subviews.insert(spot.render(), at: index)
    #else
      scrollView.contentView.insertSubview(spot.render(), at: index)
    #endif
    setupSpot(at: index, spot: spot)

    #if !os(OSX)
    (spot as? CarouselSpot)?.layout.yOffset = yOffset
    #endif
    yOffset += spot.render().frame.size.height

    scrollView.layoutIfNeeded()
  }

  fileprivate func newSpot(_ index: Int, newComponents: [Component], yOffset: inout CGFloat) {
    let spot = Factory.resolve(component: newComponents[index])
    spots.append(spot)
    setupSpot(at: index, spot: spot)
    #if !os(OSX)
      (spot as? CarouselSpot)?.layout.yOffset = yOffset
    #endif
    yOffset += spot.render().frame.size.height
  }

  /// Remove Spot at index
  ///
  /// - parameter index: The index of the Spotable object hat you want to remove
  fileprivate func removeSpot(at index: Int) {
    guard index < spots.count else { return }
    spots[index].render().removeFromSuperview()
  }

  /// Set up items for a Spotable object
  ///
  /// - parameter index:         The index of the Spotable object
  /// - parameter newComponents: A collection of new components
  /// - parameter animation:     A Animation that is used to determine which animation to use when performing the update
  /// - parameter closure:       A completion closure that is invoked when the setup of the new items is complete
  ///
  /// - returns: A boolean value that determines if the closure should run in `process(changes:)`
  fileprivate func setupItemsForSpot(at index: Int, newComponents: [Component], withAnimation animation: Animation = .automatic, completion: Completion = nil) -> Bool {
    guard let spot = self.spot(at: index, ofType: Spotable.self) else {
      return false
    }

    let newItems = spot.prepare(items: newComponents[index].items)
    let oldItems = spot.items

    guard let diff = Item.evaluate(newItems, oldModels: oldItems) else {
      return true
    }
    let changes: (ItemChanges) = Item.processChanges(diff)

    if newItems.count == spot.items.count {
      reload(in: spot, with: changes, newItems: newItems, animation: animation, completion: completion)
    } else if newItems.count < spot.items.count {
      reloadLess(in: spot, with: changes, newItems: newItems, animation: animation, completion: completion)
    } else if newItems.count > spot.items.count {
      reloadMore(in: spot, with: changes, newItems: newItems, animation: animation, completion: completion)
    }

    return false
  }

  /// Reload Spotable object with changes and new items.
  ///
  /// - parameter spot:      The spotable object that should be updated.
  /// - parameter changes:   A ItemChanges tuple.
  /// - parameter newItems:  The new items that should be used to updated the data source.
  /// - parameter animation: The animation that should be used when updating.
  /// - parameter closure:   A completion closure.
  private func reload(in spot: Spotable,
                      with changes: (ItemChanges),
                      newItems: [Item],
                      animation: Animation,
                      completion: (() -> Void)? = nil) {
    var offsets = [CGPoint]()
    spot.reloadIfNeeded(changes, withAnimation: animation, updateDataSource: {
      spot.beforeUpdate()

      for item in newItems {
        let results = spot.compositeSpots.filter({ $0.itemIndex == item.index })
        for compositeSpot in results {
          offsets.append(compositeSpot.spot.render().contentOffset)
        }
      }

      spot.items = newItems
    }) { [weak self] in
      for item in newItems {
        if let spot = self?.spots[item.index] {
          let compositeSpots = spot.compositeSpots
            .filter({ $0.itemIndex == item.index })
          for (index, compositeSpot) in compositeSpots.enumerated() {
            guard index < offsets.count else { continue }
            compositeSpot.spot.render().contentOffset = offsets[index]
          }
        }
      }

      self?.finishReloading(spot: spot, withCompletion: completion)
    }
  }

  /// Reload Spotable object with less items
  ///
  /// - parameter spot:      The spotable object that should be updated.
  /// - parameter changes:   A ItemChanges tuple.
  /// - parameter newItems:  The new items that should be used to updated the data source.
  /// - parameter animation: The animation that should be used when updating.
  /// - parameter closure:   A completion closure.
  private func reloadLess(in spot: Spotable,
                          with changes: (ItemChanges),
                          newItems: [Item],
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
//        let components = Parser.parse(item.children).map { $0.component }

//        let oldSpots = weakSelf.compositeSpots.filter({ $0.spotableIndex == spot.index })
//        for removedSpot in oldSpots {
//          guard !components.contains(removedSpot.spot.component) else {
//            continue
//          }
//
//          if let index = weakSelf.compositeSpots.index(of: removedSpot) {
//            weakSelf.compositeSpots.remove(at: index)
//          }
//        }

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

  /// Reload Spotable object with more items
  ///
  /// - parameter spot:      The spotable object that should be updated.
  /// - parameter changes:   A ItemChanges tuple.
  /// - parameter newItems:  The new items that should be used to updated the data source.
  /// - parameter animation: The animation that should be used when updating.
  /// - parameter closure:   A completion closure.
  private func reloadMore(in spot: Spotable,
                          with changes: (ItemChanges),
                          newItems: [Item],
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
        spot.updateHeight() { [weak self] in
          self?.finishReloading(spot: spot, withCompletion: completion)
        }
      }
    }
  }

  private func finishReloading(spot: Spotable, withCompletion completion: Completion = nil) {
    spot.afterUpdate()
    completion?()
    scrollView.layoutSubviews()
  }

  func process(changes: [ComponentDiff],
               components newComponents: [Component],
               withAnimation animation: Animation = .automatic,
               completion: Completion = nil) {
    Dispatch.mainQueue { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      var yOffset: CGFloat = 0.0
      var runCompletion = true

      for (index, change) in changes.enumerated() {
        switch change {
        case .identifier, .title, .kind, .span, .header, .meta:
          weakSelf.replaceSpot(index, newComponents: newComponents, yOffset: &yOffset)
        case .new:
          weakSelf.newSpot(index, newComponents: newComponents, yOffset: &yOffset)
        case .removed:
          weakSelf.removeSpot(at: index)
        case .items:
          runCompletion = weakSelf.setupItemsForSpot(at: index,
                                                  newComponents: newComponents,
                                                  withAnimation: animation,
                                                  completion: completion)
        case .none: continue
        }
      }

      for removedSpot in weakSelf.spots where removedSpot.render().superview == nil {
        if let index = weakSelf.spots.index(where: { removedSpot.component == $0.component }) {
          weakSelf.spots.remove(at: index)
        }
      }

      if runCompletion {
        completion?()

        #if os(OSX)
        for spot in weakSelf.spots {
          spot.setup(weakSelf.scrollView.frame.size)
        }
        #endif

        weakSelf.scrollView.layoutSubviews()
      }
    }
  }

  ///Reload if needed using JSON
  ///
  /// - parameter json: A JSON dictionary that gets parsed into UI elements
  /// - parameter compare: A closure that is used for comparing a Component collections
  /// - parameter animated: An animation closure that can be used to perform custom animations when reloading
  /// - parameter completion: A closure that will be run after reload has been performed on all spots
  public func reloadIfNeeded(_ json: [String : Any],
                             compare: @escaping CompareClosure = { lhs, rhs in return lhs !== rhs },
                             animated: ((_ view: View) -> Void)? = nil,
                             completion: Completion = nil) {
    Dispatch.mainQueue { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      let newSpots: [Spotable] = Parser.parse(json)
      let newComponents = newSpots.map { $0.component }
      let oldComponents = weakSelf.spots.map { $0.component }

      guard compare(newComponents, oldComponents) else {
        weakSelf.cache()
        completion?()
        return
      }

      var offsets = [CGPoint]()
//      let oldComposites = weakSelf.compositeSpots

      if newComponents.count == oldComponents.count {
        offsets = weakSelf.spots.map { $0.render().contentOffset }
      }

      weakSelf.spots = newSpots

      if weakSelf.scrollView.superview == nil {
        weakSelf.view.addSubview(weakSelf.scrollView)
      }

      weakSelf.reloadSpotsScrollView()
      weakSelf.setupSpots(animated: animated)
      weakSelf.cache()

//      for (index, compositeSpot) in oldComposites.enumerated() {
//        if index == weakSelf.compositeSpots.count {
//          break
//        }
//
//        weakSelf.compositeSpots[index].spot.render().contentOffset = compositeSpot.spot.render().contentOffset
//      }

      completion?()

      offsets.enumerated().forEach {
        newSpots[$0.offset].render().contentOffset = $0.element
      }

      if let controller = self as? Controller {
        Controller.spotsDidReloadComponents?(controller)
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
    Dispatch.mainQueue { [weak self] in
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
        Controller.spotsDidReloadComponents?(controller)
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
  public func update(spotAtIndex index: Int = 0, withAnimation animation: Animation = .automatic, withCompletion completion: Completion = nil, _ closure: (_ spot: Spotable) -> Void) {
    guard let spot = spot(at: index, ofType: Spotable.self) else {
      completion?()
      return }
    closure(spot)
    spot.refreshIndexes()
    spot.prepareItems()

    Dispatch.mainQueue { [weak self] in
      guard let weakSelf = self else { return }

      #if !os(OSX)
        if animation != .none {
          let isScrolling = weakSelf.scrollView.isDragging == true || weakSelf.scrollView.isTracking == true
          if let superview = spot.render().superview, !isScrolling {
            spot.render().frame.size.height = superview.frame.height
          }
        }
      #endif

      spot.reload(nil, withAnimation: animation) {
        spot.updateHeight() { [weak self] in
          spot.afterUpdate()
          completion?()
          self?.scrollView.layoutSubviews()
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
    guard let spot = spot(at: index, ofType: Spotable.self), !(spot.items == items) else {
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
    spot(at: spotIndex, ofType: Spotable.self)?.append(item, withAnimation: animation) { [weak self] in
      completion?()
      self?.scrollView.layoutSubviews()
    }
    spot(at: spotIndex, ofType: Spotable.self)?.refreshIndexes()
  }

  /**
   - parameter items: A collection of view models
   - parameter spotIndex: The index of the spot that you want to append to, defaults to 0
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the spot has performed updates internally
   */
  public func append(_ items: [Item], spotIndex: Int = 0, withAnimation animation: Animation = .none, completion: Completion = nil) {
    spot(at: spotIndex, ofType: Spotable.self)?.append(items, withAnimation: animation) { [weak self] in
      completion?()
      self?.scrollView.layoutSubviews()
    }
    spot(at: spotIndex, ofType: Spotable.self)?.refreshIndexes()
  }

  /**
   - parameter items: A collection of view models
   - parameter spotIndex: The index of the spot that you want to prepend to, defaults to 0
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the spot has performed updates internally
   */
  public func prepend(_ items: [Item], spotIndex: Int = 0, withAnimation animation: Animation = .none, completion: Completion = nil) {
    spot(at: spotIndex, ofType: Spotable.self)?.prepend(items, withAnimation: animation) { [weak self] in
      completion?()
      self?.scrollView.layoutSubviews()
    }
    spot(at: spotIndex, ofType: Spotable.self)?.refreshIndexes()
  }

  /**
   - parameter item: The view model that you want to insert
   - parameter index: The index that you want to insert the view model at
   - parameter spotIndex: The index of the spot that you want to insert into
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the spot has performed updates internally
   */
  public func insert(_ item: Item, index: Int = 0, spotIndex: Int, withAnimation animation: Animation = .none, completion: Completion = nil) {
    spot(at: spotIndex, ofType: Spotable.self)?.insert(item, index: index, withAnimation: animation) { [weak self] in
      completion?()
      self?.scrollView.layoutSubviews()
    }
    spot(at: spotIndex, ofType: Spotable.self)?.refreshIndexes()
  }

  /// Update item at index inside a specific Spotable object
  ///
  /// - parameter item:       The view model that you want to update.
  /// - parameter index:      The index that you want to insert the view model at.
  /// - parameter spotIndex:  The index of the spot that you want to update into.
  /// - parameter animation:  A Animation struct that determines which animation that should be used to perform the update.
  /// - parameter completion: A completion closure that will run after the spot has performed updates internally.
  public func update(_ item: Item, index: Int = 0, spotIndex: Int, withAnimation animation: Animation = .none, completion: Completion = nil) {
    guard let oldItem = spot(at: spotIndex, ofType: Spotable.self)?.item(at: index), item != oldItem
      else {
        completion?()
        return
    }

    #if os(iOS)
      if animation == .none {
        CATransaction.begin()
      }
    #endif

    spot(at: spotIndex, ofType: Spotable.self)?.update(item, index: index, withAnimation: animation) { [weak self] in
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
    spot(at: spotIndex, ofType: Spotable.self)?.reload(indexes, withAnimation: animation) {
      completion?()
    }
    spot(at: spotIndex, ofType: Spotable.self)?.refreshIndexes()
  }

  /**
   - parameter index: The index of the view model that you want to remove
   - parameter spotIndex: The index of the spot that you want to remove into
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the spot has performed updates internally
   */
  public func delete(_ index: Int, spotIndex: Int = 0, withAnimation animation: Animation = .none, completion: Completion = nil) {
    spot(at: spotIndex, ofType: Spotable.self)?.delete(index, withAnimation: animation) {
      completion?()
    }
    spot(at: spotIndex, ofType: Spotable.self)?.refreshIndexes()
  }

  /**
   - parameter indexes: A collection of indexes for view models that you want to remove
   - parameter spotIndex: The index of the spot that you want to remove into
   - parameter animation: A Animation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the spot has performed updates internally
   */
  public func delete(_ indexes: [Int], spotIndex: Int = 0, withAnimation animation: Animation = .none, completion: Completion = nil) {
    spot(at: spotIndex, ofType: Spotable.self)?.delete(indexes, withAnimation: animation) {
      completion?()
    }
    spot(at: spotIndex, ofType: Spotable.self)?.refreshIndexes()
  }

  #if os(iOS)
  public func refreshSpots(_ refreshControl: UIRefreshControl) {
    Dispatch.mainQueue { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.refreshPositions.removeAll()
      weakSelf.refreshDelegate?.spotsDidReload(refreshControl) {
        refreshControl.endRefreshing()
      }
    }
  }
  #endif

  fileprivate func reloadSpotsScrollView() {
    #if os(OSX)
      scrollView.documentView?.subviews.forEach { $0.removeFromSuperview() }
    #else
      scrollView.contentView.subviews.forEach { $0.removeFromSuperview() }
    #endif
  }
}
