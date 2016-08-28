#if os(iOS)
  import UIKit
#else
  import Foundation
#endif

import Sugar
import Brick
import Cache

public protocol SpotsProtocol: class {
  /// A SpotCache object
  var stateCache: SpotCache? { get set }
  /// The internal SpotsScrollView
  var spotsScrollView: SpotsScrollView { get }
  /// A delegate that conforms to SpotsDelegate
  var spotsDelegate: SpotsDelegate? { get }
  /// A collection of Spotable objects
  var spots: [Spotable] { get set }
  /// An array of refresh position to avoid calling multiple refreshes
  var refreshPositions: [CGFloat] { get set }
  /// A view controller view
  #if os(OSX)
  var view: View { get }
  #else
  var view: View! { get }
  #endif

  var spot: Spotable? { get }

  /// A dictionary representation of the controller
  var dictionary: JSONDictionary { get }

  #if os(iOS)
  var spotsRefreshDelegate: SpotsRefreshDelegate? { get set }
  #endif

  #if DEVMODE
  var fileQueue: dispatch_queue_t { get }
  var source: dispatch_source_t! { get set }
  #endif

  func setupSpots(animated: ((view: View) -> Void)?)
  func spot<T>(index: Int, _ type: T.Type) -> T?
  func spot(@noescape closure: (index: Int, spot: Spotable) -> Bool) -> Spotable?

  #if os(OSX)
  init(spots: [Spotable], backgroundType: SpotsControllerBackground)
  #else
  init(spots: [Spotable])
  #endif

}

public extension SpotsProtocol {

  public var dictionary: JSONDictionary {
    get { return dictionary() }
  }

  public func dictionary(amountOfItems: Int? = nil) -> JSONDictionary {
    return ["components" : spots.map { $0.component.dictionary(amountOfItems) }]
  }

  /**
   - Parameter includeElement: A filter predicate to find a spot
   */
  public func filter(@noescape includeElement: (Spotable) -> Bool) -> [Spotable] {
    return spots.filter(includeElement)
  }

  public func filterItems(@noescape includeElement: (ViewModel) -> Bool) -> [(spot: Spotable, items: [ViewModel])] {
    var result = [(spot: Spotable, items: [ViewModel])]()
    for spot in spots {
      let items = spot.items.filter(includeElement)
      if !items.isEmpty {
        result.append((spot: spot, items: items))
      }
    }

    return result
  }

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

      let newSpots = Parser.parse(json)
      let newComponents = newSpots.map { $0.component }
      let oldComponents = weakSelf.spots.map { $0.component }

      guard compare(lhs: newComponents, rhs: oldComponents) else {
        weakSelf.cache()
        closure?()
        return
      }

      var offsets = [CGPoint]()
      if newComponents.count == oldComponents.count {
        offsets = weakSelf.spots.map { $0.render().contentOffset }
      }

      weakSelf.spots = newSpots
      weakSelf.cache()

      if weakSelf.spotsScrollView.superview == nil {
        weakSelf.view.addSubview(weakSelf.spotsScrollView)
      }

      weakSelf.reloadSpotsScrollView()
      weakSelf.setupSpots(animated)

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
#if os(iOS)
  /**
   - Parameter index: The index of the spot that you want to scroll
   - Parameter includeElement: A filter predicate to find a view model
   */
  public func scrollTo(spotIndex index: Int = 0, @noescape includeElement: (ViewModel) -> Bool) {
    guard let itemY = spot(index, Spotable.self)?.scrollTo(includeElement) else { return }

    var initialHeight: CGFloat = 0.0
    if index > 0 {
      initialHeight += spots[0..<index].reduce(0, combine: { $0 + $1.spotHeight() })
    }
    if spot(index, Spotable.self)?.spotHeight() > spotsScrollView.frame.height - spotsScrollView.contentInset.bottom - initialHeight {
      let y = itemY - spotsScrollView.frame.size.height + spotsScrollView.contentInset.bottom + initialHeight
      spotsScrollView.setContentOffset(CGPoint(x: CGFloat(0.0), y: y), animated: true)
    }
  }

  /**
   - Parameter animated: A boolean value to determine if you want to perform the scrolling with or without animation
   */
  public func scrollToBottom(animated: Bool) {
    let y = spotsScrollView.contentSize.height - spotsScrollView.frame.size.height + spotsScrollView.contentInset.bottom
    spotsScrollView.setContentOffset(CGPoint(x: 0, y: y), animated: animated)
  }
#endif

  /**
   Caches the current state of the spot controller
   */
  public func cache(items items: Int? = nil) {
    #if DEVMODE
      liveEditing(stateCache)
    #endif

    stateCache?.save(dictionary(items))
  }

  /**
   Clear Spots cache
   */
  public static func clearCache() {
    let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory,
                                                    NSSearchPathDomainMask.UserDomainMask, true)
    let path = "\(paths.first!)/\(DiskStorage.prefix).\(SpotCache.cacheName)"
    do {
      try NSFileManager.defaultManager().removeItemAtPath(path)
    } catch {
      NSLog("Could not remove cache at path: \(path)")
    }
  }

  /**
   - Parameter indexPath: The index path of the component you want to lookup
   - Returns: A Component object at index path
   **/
  private func component(indexPath: NSIndexPath) -> Component {
    return spot(indexPath).component
  }

  /**
   - Parameter indexPath: The index path of the spot you want to lookup
   - Returns: A Spotable object at index path
   **/
  private func spot(indexPath: NSIndexPath) -> Spotable {
    return spots[indexPath.item]
  }

  #if DEVMODE

  private func monitor(filePath: String) {
    guard NSFileManager.defaultManager().fileExistsAtPath(filePath) else { return }

    source = dispatch_source_create(
      DISPATCH_SOURCE_TYPE_VNODE,
      UInt(open(filePath, O_EVTONLY)),
      DISPATCH_VNODE_DELETE | DISPATCH_VNODE_WRITE | DISPATCH_VNODE_EXTEND | DISPATCH_VNODE_ATTRIB | DISPATCH_VNODE_LINK | DISPATCH_VNODE_RENAME | DISPATCH_VNODE_REVOKE,
      fileQueue)

    dispatch_source_set_event_handler(source, {
      // Check that file still exists, otherwise cancel observering
      guard NSFileManager.defaultManager().fileExistsAtPath(filePath) else {
        dispatch_source_cancel(self.source)
        self.source = nil
        return
      }

      do {
        if let data = NSData(contentsOfFile: filePath),
          json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [String : AnyObject] {
          dispatch_source_cancel(self.source)
          self.source = nil
          let offset = self.spotsScrollView.contentOffset
          self.reloadIfNeeded(json, compare: { $0 !== $1 }) {
            self.spotsScrollView.contentOffset = offset

            for case let gridable as CarouselSpot in self.spots {
              (gridable.layout as? GridableLayout)?.y = gridable.render().frame.origin.y
            }
          }
        }
      } catch let error {
        self.liveEditing(self.stateCache)
      }
    })

    dispatch_resume(source)
  }

  private func liveEditing(stateCache: SpotCache?) {
  #if os(iOS)
    guard let stateCache = stateCache where source == nil && Simulator.isRunning else { return }
  #else
    guard let stateCache = stateCache else { return }
  #endif
    CacheJSONOptions.writeOptions = .PrettyPrinted

    let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory,
                                                    NSSearchPathDomainMask.UserDomainMask, true)

    NSLog("-----[\(stateCache.key)]-----\n\nfile://\(stateCache.path)\n\n")
    delay(0.5) { self.monitor(stateCache.path) }
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
