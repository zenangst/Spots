#if os(iOS)
  import UIKit
#else
  import Foundation
#endif

import Sugar
import Brick

extension SpotsProtocol {

  /**
   - Parameter completion: A closure that will be run after reload has been performed on all spots
   */
  public func reload(animated: Bool = true, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    var spotsLeft = spots.count

    dispatch { [weak self] in
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
  public func reloadIfNeeded(components: [Component], closure: Completion = nil) {
    dispatch(queue: .Interactive) {
      let newComponents = components
      let oldComponents = self.spots.map { $0.component }

      guard newComponents !== oldComponents else {
        dispatch { closure?() }
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

      self.process(changes: changes, components: newComponents) {
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

  private func setupItemsForSpot(index: Int, newComponents: [Component], closure: Completion = nil) -> Bool {
    guard let spot = self.spot(index, Spotable.self) else { return false }
    let newItems = newComponents[index].items
    let oldItems = spot.items

    guard let diff = ViewModel.evaluate(newItems, oldModels: oldItems) else { return false }
    let changes = ViewModel.processChanges(diff)

    if newItems.count == spot.items.count {
      var offsets = [CGPoint]()
      spot.adapter?.reloadIfNeeded(changes, updateDataSource: {
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
      spot.adapter?.reloadIfNeeded(changes, updateDataSource: {
        CATransaction.begin()
        spot.items = newItems
      }) {
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
          spot.update(item, index: index, withAnimation: .Automatic) {
            guard index == executeClosure else { return }
            closure?()
            self.spotsScrollView.forceUpdate = true
            CATransaction.commit()
          }
        }
      }
    } else if newItems.count > spot.items.count {
      spot.adapter?.reloadIfNeeded(changes, updateDataSource: {
        CATransaction.begin()
        spot.items = newItems
      }) {
        spot.adapter?.reload(nil, withAnimation: .None) {
          closure?()
          delay(0.1) {
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
                                  closure: Completion = nil) {
    dispatch {
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
          runClosure = self.setupItemsForSpot(index, newComponents: newComponents, closure: closure)
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
   - Parameter json: A JSON dictionary that gets parsed into UI elements
   - Parameter completion: A closure that will be run after reload has been performed on all spots
   */
  public func reloadIfNeeded(json: [String : AnyObject],
                             compare: ((lhs: [Component], rhs: [Component]) -> Bool) = { lhs, rhs in return lhs != rhs },
                             animated: ((view: View) -> Void)? = nil,
                             closure: Completion = nil) {
    dispatch { [weak self] in
      guard let weakSelf = self else { closure?(); return }

      let newSpots: [Spotable] = Parser.parse(json)
      let newComponents = newSpots.map { $0.component }
      let oldComponents = weakSelf.spots.map { $0.component }

      guard compare(lhs: newComponents, rhs: oldComponents) else {
        weakSelf.cache()
        closure?()
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

      closure?()
      weakSelf.spotsScrollView.forceUpdate = true

      offsets.enumerate().forEach {
        newSpots[$0.index].render().contentOffset = $0.element
      }
    }
  }

  /**
   - Parameter json: A JSON dictionary that gets parsed into UI elements
   - Parameter completion: A closure that will be run after reload has been performed on all spots
   */
  public func reload(json: [String : AnyObject], animated: ((view: View) -> Void)? = nil, closure: Completion = nil) {
    dispatch { [weak self] in
      guard let weakSelf = self else { closure?(); return }

      weakSelf.spots = Parser.parse(json)
      weakSelf.cache()

      if weakSelf.spotsScrollView.superview == nil {
        weakSelf.view.addSubview(weakSelf.spotsScrollView)
      }

      weakSelf.reloadSpotsScrollView()
      weakSelf.setupSpots(animated)

      closure?()
      weakSelf.spotsScrollView.forceUpdate = true
    }
  }

  /**
   - Parameter spotAtIndex: The index of the spot that you want to perform updates on
   - Parameter animated: Perform reload animation
   - Parameter closure: A transform closure to perform the proper modification to the target spot before updating the internals
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

    dispatch { [weak self] in
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
   - Parameter spotAtIndex: The index of the spot that you want to perform updates on
   - Parameter items: An array of view models
   */
  public func updateIfNeeded(spotAtIndex index: Int = 0, items: [ViewModel], withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
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
   - Parameter item: The view model that you want to append
   - Parameter spotIndex: The index of the spot that you want to append to, defaults to 0
   - Parameter closure: A completion closure that will run after the spot has performed updates internally
   */
  public func append(item: ViewModel, spotIndex: Int = 0, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    spot(spotIndex, Spotable.self)?.append(item, withAnimation: animation) {
      completion?()
      self.spotsScrollView.forceUpdate = true
    }
    spot(spotIndex, Spotable.self)?.refreshIndexes()
  }

  /**
   - Parameter items: A collection of view models
   - Parameter spotIndex: The index of the spot that you want to append to, defaults to 0
   - Parameter closure: A completion closure that will run after the spot has performed updates internally
   */
  public func append(items: [ViewModel], spotIndex: Int = 0, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    spot(spotIndex, Spotable.self)?.append(items, withAnimation: animation) {
      completion?()
      self.spotsScrollView.forceUpdate = true
    }
    spot(spotIndex, Spotable.self)?.refreshIndexes()
  }

  /**
   - Parameter items: A collection of view models
   - Parameter spotIndex: The index of the spot that you want to prepend to, defaults to 0
   - Parameter closure: A completion closure that will run after the spot has performed updates internally
   */
  public func prepend(items: [ViewModel], spotIndex: Int = 0, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    spot(spotIndex, Spotable.self)?.prepend(items, withAnimation: animation) {
      completion?()
      self.spotsScrollView.forceUpdate = true
    }
    spot(spotIndex, Spotable.self)?.refreshIndexes()
  }

  /**
   - Parameter item: The view model that you want to insert
   - Parameter index: The index that you want to insert the view model at
   - Parameter spotIndex: The index of the spot that you want to insert into
   - Parameter closure: A completion closure that will run after the spot has performed updates internally
   */
  public func insert(item: ViewModel, index: Int = 0, spotIndex: Int, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    spot(spotIndex, Spotable.self)?.insert(item, index: index, withAnimation: animation) {
      completion?()
      self.spotsScrollView.forceUpdate = true
    }
    spot(spotIndex, Spotable.self)?.refreshIndexes()
  }

  /**
   - Parameter item: The view model that you want to update
   - Parameter index: The index that you want to insert the view model at
   - Parameter spotIndex: The index of the spot that you want to update into
   - Parameter closure: A completion closure that will run after the spot has performed updates internally
   */
  public func update(item: ViewModel, index: Int = 0, spotIndex: Int, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
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
   - Parameter indexes: An integer array of indexes that you want to update
   - Parameter spotIndex: The index of the spot that you want to update into
   - Parameter animated: Perform reload animation
   - Parameter closure: A completion closure that will run after the spot has performed updates internally
   */
  public func update(indexes indexes: [Int], spotIndex: Int = 0, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    spot(spotIndex, Spotable.self)?.reload(indexes, withAnimation: animation) {
      completion?()
      self.spotsScrollView.forceUpdate = true
    }
    spot(spotIndex, Spotable.self)?.refreshIndexes()
  }

  /**
   - Parameter index: The index of the view model that you want to remove
   - Parameter spotIndex: The index of the spot that you want to remove into
   - Parameter closure: A completion closure that will run after the spot has performed updates internally
   */
  public func delete(index: Int, spotIndex: Int = 0, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    spot(spotIndex, Spotable.self)?.delete(index, withAnimation: animation) {
      completion?()
      self.spotsScrollView.forceUpdate = true
    }
    spot(spotIndex, Spotable.self)?.refreshIndexes()
  }

  /**
   - Parameter indexes: A collection of indexes for view models that you want to remove
   - Parameter spotIndex: The index of the spot that you want to remove into
   - Parameter closure: A completion closure that will run after the spot has performed updates internally
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
    dispatch { [weak self] in
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
