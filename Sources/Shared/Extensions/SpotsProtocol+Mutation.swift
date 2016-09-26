#if os(iOS)
  import UIKit
#else
  import Foundation
#endif

import Brick

extension SpotsProtocol {

  public typealias CompareClosure = ((lhs: [Component], rhs: [Component]) -> Bool)

  /**
   Reload all Spotable objects

   - parameter animated:   A boolean value that indicates if animations should be applied, defaults to true
   - parameter animation:  A SpotableAnimation struct that determines which animation that should be used for the updates
   - parameter completion: A completion block that is run when the reloading is done
   */
  public func reload(animated: Bool = true, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    var spotsLeft = spots.count

    Dispatch.mainQueue { [weak self] in
      self?.spots.forEach { spot in
        spot.reload([], withAnimation: animation) {
          spotsLeft -= 1

          if spotsLeft == 0 {
            completion?()
            self?.spotsScrollView.forceUpdate = true
          }
        }
      }
    }
  }

  #if !os(OSX)
  public func reloadIfNeeded(components: [Component], withAnimation animation: SpotsAnimation = .Automatic, closure: Completion = nil) {
    Dispatch.inQueue(queue: .Interactive) {
      let newComponents = components
      let oldComponents = self.spots.map { $0.component }

      guard newComponents !== oldComponents else {
        Dispatch.mainQueue { closure?() }
        return
      }

      let oldComponentCount = oldComponents.count

      var changes = [ComponentDiff]()
      for (index, component) in components.enumerate() {
        if index >= oldComponentCount {
          changes.append(.New)
          continue
        }

        changes.append(component.diff(component: oldComponents[index]))
      }

      if oldComponentCount > components.count {
        oldComponents[components.count..<oldComponents.count].forEach { _ in
          changes.append(.Removed)
        }
      }

      self.process(changes: changes, components: newComponents, withAnimation: animation) {
        closure?()
        self.spotsScrollView.forceUpdate = true
      }
    }
  }

  func removeCompositeViews() {
    for (_, cSpots) in self.compositeSpots {
      for (_, spots) in cSpots.enumerate() {
        for spot in spots.1 {
          spot.render().removeFromSuperview()
        }
      }
    }
  }

  private func replaceSpot(index: Int, newComponents: [Component], inout yOffset: CGFloat) {
    let spot = SpotFactory.resolve(newComponents[index])

    self.removeCompositeViews()
    self.spots[index].render().removeFromSuperview()
    self.spots[index] = spot
    self.setupSpot(index, spot: spot)
    self.spotsScrollView.contentView.insertSubview(spot.render(), atIndex: index)
    (spot as? Gridable)?.layout.yOffset = yOffset
    yOffset += spot.render().frame.size.height
  }

  private func newSpot(index: Int, newComponents: [Component], inout yOffset: CGFloat) {
    let spot = SpotFactory.resolve(newComponents[index])
    self.spots.append(spot)
    self.setupSpot(index, spot: spot)
    (spot as? Gridable)?.layout.yOffset = yOffset
    self.spotsScrollView.contentView.addSubview(spot.render())
    yOffset += spot.render().frame.size.height
  }

  private func removeSpot(index: Int) {
    if index < self.spots.count {
      self.spots.removeAtIndex(index)
    }
  }

  /**
   Set up items for a Spotable object

   - parameter index: The index of the Spotable object
   - parameter newComponents: A collection of new components
   - parameter animation: A SpotAnimation that is used to determine which animation to use when performing the update
   - parameter closure: A completion closure that is invoked when the setup of the new items is complete

   - returns: A boolean value that determines if the closure should run in `process(changes:)`
   */
  private func setupItemsForSpot(index: Int, newComponents: [Component], withAnimation animation: SpotsAnimation = .Automatic, closure: Completion = nil) -> Bool {
    guard let spot = self.spot(index, Spotable.self) else { return false }
    let newItems = newComponents[index].items
    let oldItems = spot.items

    guard let diff = Item.evaluate(newItems, oldModels: oldItems) else { closure?(); return false }
    let changes = Item.processChanges(diff)

    if newItems.count == spot.items.count {
      var offsets = [CGPoint]()
      spot.adapter?.reloadIfNeeded(changes, withAnimation: animation, updateDataSource: {
        CATransaction.begin()
        for item in newItems {
          if let compositeSpots = self.compositeSpots[spot.index],
            spots = compositeSpots[item.index] {
            for spot in spots {
              offsets.append(spot.render().contentOffset)
            }
          }
        }

        spot.items = newItems
      }) {
        for item in newItems {
          if let compositeSpots = self.compositeSpots[spot.index],
            spots = compositeSpots[item.index] {
            for (index, spot) in spots.enumerate() {
              guard index < offsets.count else { continue }
              spot.render().contentOffset = offsets[index]
            }
          }
        }

        self.spotsScrollView.forceUpdate = true
        closure?()
        CATransaction.commit()
      }
    } else if newItems.count < spot.items.count {
      spot.adapter?.reloadIfNeeded(changes, withAnimation: animation, updateDataSource: {
        CATransaction.begin()
        spot.items = newItems
      }) {
        guard !newItems.isEmpty else {
          closure?()
          self.spotsScrollView.forceUpdate = true
          CATransaction.commit()
          return
        }

        let executeClosure = newItems.count - 1
        for (index, item) in newItems.enumerate() {
          let components = Parser.parse(item.children).map { $0.component }
          if let compositeSpots = self.compositeSpots[spot.index],
            spots = compositeSpots[item.index] {
            for (index, removedSpot) in spots.enumerate() {
              guard !components.contains(removedSpot.component) else { continue }
              var oldContent = self.compositeSpots[spot.index]?[item.index]
              if index < oldContent?.count {
                oldContent?.removeAtIndex(index)
              }
              self.compositeSpots[spot.index]?[item.index] = oldContent
            }
          }
          spot.update(item, index: index, withAnimation: animation) {
            guard index == executeClosure else { return }
            closure?()
            self.spotsScrollView.forceUpdate = true
            CATransaction.commit()
          }
        }
      }
    } else if newItems.count > spot.items.count {
      spot.adapter?.reloadIfNeeded(changes, withAnimation: animation, updateDataSource: {
        CATransaction.begin()
        spot.items = newItems
      }) {
        spot.adapter?.reload(nil, withAnimation: animation) {
          closure?()
          Dispatch.delay(for: 0.1) {
            self.spotsScrollView.forceUpdate = true
            CATransaction.commit()
          }
        }
      }
    }

    return false
  }

  func process(changes changes: [ComponentDiff],
                       components newComponents: [Component],
                                  withAnimation animation: SpotsAnimation = .Automatic,
                                  closure: Completion = nil) {
    Dispatch.mainQueue {
      var yOffset: CGFloat = 0.0
      var runClosure = true
      for (index, change) in changes.enumerate() {
        switch change {
        case .Identifier, .Kind, .Span, .Header, .Meta:
          self.replaceSpot(index, newComponents: newComponents, yOffset: &yOffset)
        case .New:
          self.newSpot(index, newComponents: newComponents, yOffset: &yOffset)
        case .Removed:
          self.removeSpot(index)
        case .Items:
          runClosure = self.setupItemsForSpot(index,
            newComponents: newComponents,
            withAnimation: animation,
            closure: closure)
        case .None: break
        }
      }

      if runClosure {
        closure?()
      }
    }
  }
  #endif

  /**
   Reload if needed using JSON

   - parameter json: A JSON dictionary that gets parsed into UI elements
   - parameter compare: A closure that is used for comparing a Component collections
   - parameter animated: An animation closure that can be used to perform custom animations when reloading
   - parameter completion: A closure that will be run after reload has been performed on all spots
   */
  public func reloadIfNeeded(json: [String : AnyObject],
                             compare: CompareClosure = { lhs, rhs in return lhs != rhs },
                             animated: ((view: View) -> Void)? = nil,
                             completion: Completion = nil) {
    Dispatch.mainQueue { [weak self] in
      guard let weakSelf = self else { completion?(); return }

      let newSpots: [Spotable] = Parser.parse(json)
      let newComponents = newSpots.map { $0.component }
      let oldComponents = weakSelf.spots.map { $0.component }

      guard compare(lhs: newComponents, rhs: oldComponents) else {
        weakSelf.cache()
        completion?()
        return
      }

      var offsets = [CGPoint]()
      var oldComposite = weakSelf.compositeSpots

      if newComponents.count == oldComponents.count {
        offsets = weakSelf.spots.map { $0.render().contentOffset }
      }

      weakSelf.spots = newSpots

      if weakSelf.spotsScrollView.superview == nil {
        weakSelf.view.addSubview(weakSelf.spotsScrollView)
      }

      weakSelf.reloadSpotsScrollView()
      weakSelf.setupSpots(animated)
      weakSelf.cache()

      for (index, container) in weakSelf.compositeSpots.enumerate() {
        guard let itemIndex = container.1.keys.first,
          foundContainer = weakSelf.compositeSpots[index]?[itemIndex] else { continue }

        for (spotIndex, spot) in foundContainer.enumerate() {
          guard let rootContainer = oldComposite[index],
            itemContainer = rootContainer[itemIndex]
            where spotIndex < itemContainer.count else { continue }

          spot.render().contentOffset = itemContainer[spotIndex].render().contentOffset
        }
      }

      completion?()
      weakSelf.spotsScrollView.forceUpdate = true

      offsets.enumerate().forEach {
        newSpots[$0.index].render().contentOffset = $0.element
      }
    }
  }

  /**
   - parameter json: A JSON dictionary that gets parsed into UI elements
   - parameter animated: An animation closure that can be used to perform custom animations when reloading
   - parameter completion: A closure that will be run after reload has been performed on all spots
   */
  public func reload(json: [String : AnyObject], animated: ((view: View) -> Void)? = nil, completion: Completion = nil) {
    Dispatch.mainQueue { [weak self] in
      guard let weakSelf = self else { completion?(); return }

      weakSelf.spots = Parser.parse(json)
      weakSelf.cache()

      if weakSelf.spotsScrollView.superview == nil {
        weakSelf.view.addSubview(weakSelf.spotsScrollView)
      }

      weakSelf.reloadSpotsScrollView()
      weakSelf.setupSpots(animated)

      completion?()
      weakSelf.spotsScrollView.forceUpdate = true
    }
  }

  /**
   - parameter spotAtIndex: The index of the spot that you want to perform updates on
   - parameter animation: A SpotAnimation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that is performed when the update is completed
   - parameter closure: A transform closure to perform the proper modification to the target spot before updating the internals
   */
  public func update(spotAtIndex index: Int = 0, withAnimation animation: SpotsAnimation = .Automatic, withCompletion completion: Completion = nil, @noescape _ closure: (spot: Spotable) -> Void) {
    guard let spot = spot(index, Spotable.self) else {
      completion?()
      self.spotsScrollView.forceUpdate = true
      return }
    closure(spot: spot)
    spot.refreshIndexes()
    spot.registerAndPrepare()
    let spotHeight = spot.spotHeight()

    Dispatch.mainQueue { [weak self] in
      guard let weakSelf = self else { return }

      #if !os(OSX)
        if animation != .None { spot.render().layer.frame.size.height = spotHeight }
      #endif

      weakSelf.spot(index, Spotable.self)?.reload(nil, withAnimation: animation) {
        completion?()
        weakSelf.spotsScrollView.forceUpdate = true
      }
    }
  }

  /**
   Updates spot only if the passed view models are not the same with the current ones.

   - parameter spotAtIndex: The index of the spot that you want to perform updates on
   - parameter items: An array of view models
   - parameter animation: A SpotAnimation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that is run when the update is completed
   */
  public func updateIfNeeded(spotAtIndex index: Int = 0, items: [Item], withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    guard let spot = spot(index, Spotable.self) where !(spot.items == items) else {
      completion?()
      self.spotsScrollView.forceUpdate = true
      return
    }

    update(spotAtIndex: index, withAnimation: animation, withCompletion: completion, {
      $0.items = items
      self.spotsScrollView.forceUpdate = true
    })
  }

  /**
   - parameter item: The view model that you want to append
   - parameter spotIndex: The index of the spot that you want to append to, defaults to 0
   - parameter animation: A SpotAnimation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the spot has performed updates internally
   */
  public func append(item: Item, spotIndex: Int = 0, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    spot(spotIndex, Spotable.self)?.append(item, withAnimation: animation) {
      completion?()
      self.spotsScrollView.forceUpdate = true
    }
    spot(spotIndex, Spotable.self)?.refreshIndexes()
  }

  /**
   - parameter items: A collection of view models
   - parameter spotIndex: The index of the spot that you want to append to, defaults to 0
   - parameter animation: A SpotAnimation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the spot has performed updates internally
   */
  public func append(items: [Item], spotIndex: Int = 0, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    spot(spotIndex, Spotable.self)?.append(items, withAnimation: animation) {
      completion?()
      self.spotsScrollView.forceUpdate = true
    }
    spot(spotIndex, Spotable.self)?.refreshIndexes()
  }

  /**
   - parameter items: A collection of view models
   - parameter spotIndex: The index of the spot that you want to prepend to, defaults to 0
   - parameter animation: A SpotAnimation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the spot has performed updates internally
   */
  public func prepend(items: [Item], spotIndex: Int = 0, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    spot(spotIndex, Spotable.self)?.prepend(items, withAnimation: animation) {
      completion?()
      self.spotsScrollView.forceUpdate = true
    }
    spot(spotIndex, Spotable.self)?.refreshIndexes()
  }

  /**
   - parameter item: The view model that you want to insert
   - parameter index: The index that you want to insert the view model at
   - parameter spotIndex: The index of the spot that you want to insert into
   - parameter animation: A SpotAnimation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the spot has performed updates internally
   */
  public func insert(item: Item, index: Int = 0, spotIndex: Int, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    spot(spotIndex, Spotable.self)?.insert(item, index: index, withAnimation: animation) {
      completion?()
      self.spotsScrollView.forceUpdate = true
    }
    spot(spotIndex, Spotable.self)?.refreshIndexes()
  }

  /**
   - parameter item: The view model that you want to update
   - parameter index: The index that you want to insert the view model at
   - parameter spotIndex: The index of the spot that you want to update into
   - parameter animation: A SpotAnimation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the spot has performed updates internally
   */
  public func update(item: Item, index: Int = 0, spotIndex: Int, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    guard let oldItem = spot(spotIndex, Spotable.self)?.item(index) where item != oldItem
      else {
        spot(spotIndex, Spotable.self)?.refreshIndexes()
        completion?()
        self.spotsScrollView.forceUpdate = true
        return
    }

    spot(spotIndex, Spotable.self)?.update(item, index: index, withAnimation: animation) {
      completion?()
      self.spotsScrollView.forceUpdate = true
    }
    spot(spotIndex, Spotable.self)?.refreshIndexes()
  }

  /**
   - parameter indexes: An integer array of indexes that you want to update
   - parameter spotIndex: The index of the spot that you want to update into
   - parameter animation: A SpotAnimation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the spot has performed updates internally
   */
  public func update(indexes indexes: [Int], spotIndex: Int = 0, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    spot(spotIndex, Spotable.self)?.reload(indexes, withAnimation: animation) {
      completion?()
      self.spotsScrollView.forceUpdate = true
    }
    spot(spotIndex, Spotable.self)?.refreshIndexes()
  }

  /**
   - parameter index: The index of the view model that you want to remove
   - parameter spotIndex: The index of the spot that you want to remove into
   - parameter animation: A SpotAnimation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the spot has performed updates internally
   */
  public func delete(index: Int, spotIndex: Int = 0, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    spot(spotIndex, Spotable.self)?.delete(index, withAnimation: animation) {
      completion?()
      self.spotsScrollView.forceUpdate = true
    }
    spot(spotIndex, Spotable.self)?.refreshIndexes()
  }

  /**
   - parameter indexes: A collection of indexes for view models that you want to remove
   - parameter spotIndex: The index of the spot that you want to remove into
   - parameter animation: A SpotAnimation struct that determines which animation that should be used to perform the update
   - parameter completion: A completion closure that will run after the spot has performed updates internally
   */
  public func delete(indexes indexes: [Int], spotIndex: Int = 0, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    spot(spotIndex, Spotable.self)?.delete(indexes, withAnimation: animation) {
      completion?()
      self.spotsScrollView.forceUpdate = true
    }
    spot(spotIndex, Spotable.self)?.refreshIndexes()
  }

  #if os(iOS)
  public func refreshSpots(refreshControl: UIRefreshControl) {
    Dispatch.mainQueue { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.refreshPositions.removeAll()
      weakSelf.spotsRefreshDelegate?.spotsDidReload(refreshControl) {
        refreshControl.endRefreshing()
      }
    }
  }
  #endif

  private func reloadSpotsScrollView() {
    #if os(OSX)
      (spotsScrollView.documentView as? View)?.subviews.forEach { $0.removeFromSuperview() }
    #else
      spotsScrollView.contentView.subviews.forEach { $0.removeFromSuperview() }
    #endif
  }
}
