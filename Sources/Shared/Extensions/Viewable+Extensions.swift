#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif

/// A Spotable extension for Viewable objects
public extension Spotable where Self : Viewable {

  /**
   - returns: UIScrollView: A UIScrollView container for your view
   */
  var view: ScrollView {
    return scrollView
  }

  /**
   - parameter size: A CGSize to set the size of the view
   */
  func layout(_ size: CGSize) {
    view.frame.size = size
    #if os(iOS)
      scrollView.contentSize = size
    #endif
  }

  /**
   Called when the Gridable object is being prepared, it is required by Spotable
   */
  public func prepare() {
    prepareSpot(self)
  }

  fileprivate func prepareSpot<T: Viewable>(_ spot: T) {
    if component.kind.isEmpty { component.kind = "view" }

    component.items.forEach { (item: Item) in
      if case let Registry.Item.classType(classType)? = T.views.storage[item.kind], T.views.storage.keys.contains(item.kind) {
        let view = classType.init()

        if let itemConfigurable = view as? ContentConfigurable {
          itemConfigurable.configure(&component.items[index])
          view.frame.size = itemConfigurable.preferredViewSize
        }

        scrollView.addSubview(view)
      }
    }
  }

  func setup(_ size: CGSize) {
    let height = component.items.reduce(0, { $0 + $1.size.height })
    let size = CGSize(width: size.width, height: height)
    view.frame.size = size
    #if os(iOS)
      scrollView.contentSize = size
    #endif

    component.items.enumerated().forEach {
      component.items[$0.offset].size.width = size.width
      scrollView.subviews[$0.offset].frame.size.width = size.width
    }
  }

  /// Append item to collection with animation
  ///
  /// - parameter item: The view model that you want to append.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  func append(_ item: Item, withAnimation animation: Animation = .none, completion: Completion = nil) {
    let dynamic = type(of: self)

    guard case let Registry.Item.classType(classType)? = dynamic.views.storage[item.kind], dynamic.views.storage.keys.contains(item.kind) else { return }

    let view = classType.init()
    (view as? ContentConfigurable)?.configure(&component.items[index])
    if let size = (view as? ContentConfigurable)?.preferredViewSize {
      view.frame.size = size
    }

    scrollView.addSubview(view)
    component.items.append(item)
  }

  /// Append a collection of items to collection with animation
  ///
  /// - parameter items:      A collection of view models that you want to insert
  /// - parameter animation:  The animation that should be used (currently not in use)
  /// - parameter completion: A completion closure that is executed in the main queue.
  func append(_ items: [Item], withAnimation animation: Animation = .none, completion: Completion = nil) {
    for item in items {
      let dynamic = type(of: self)

      guard case let Registry.Item.classType(classType)? = dynamic.views.storage[item.kind], dynamic.views.storage.keys.contains(item.kind) else { return }

      let view = classType.init()
      (view as? ContentConfigurable)?.configure(&component.items[index])
      if let size = (view as? ContentConfigurable)?.preferredViewSize {
        view.frame.size = size
      }

      scrollView.addSubview(view)
      component.items.append(item)
    }
  }

  /// Insert item into collection at index.
  ///
  /// - parameter item:       The view model that you want to insert.
  /// - parameter index:      The index where the new Item should be inserted.
  /// - parameter animation:  A Animation that is used when performing the mutation (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  func insert(_ item: Item, index: Int, withAnimation animation: Animation = .none, completion: Completion = nil) {
    let dynamic = type(of: self)

    guard case let Registry.Item.classType(classType)? = dynamic.views.storage[item.kind], dynamic.views.storage.keys.contains(item.kind) else { return }

    let view = classType.init()
    (view as? ContentConfigurable)?.configure(&component.items[index])
    if let size = (view as? ContentConfigurable)?.preferredViewSize {
      view.frame.size = size
    }
    #if os(iOS)
      scrollView.insertSubview(view, at: index)
    #endif
    component.items.insert(item, at: index)
  }

  /// Prepend a collection items to the collection with animation
  ///
  /// - parameter items:      A collection of view model that you want to prepend
  /// - parameter animation:  A Animation that is used when performing the mutation (currently not in use)
  /// - parameter completion: A completion closure that is executed in the main queue.
  func prepend(_ items: [Item], withAnimation animation: Animation = .none, completion: Completion = nil) {
    component.items.insert(contentsOf: items, at: 0)

    for item in items.reversed() {
      let dynamic = type(of: self)

      guard case let Registry.Item.classType(classType)? = dynamic.views.storage[item.kind], dynamic.views.storage.keys.contains(item.kind) else { return }

      let view = classType.init()
      (view as? ContentConfigurable)?.configure(&component.items[index])
      if let size = (view as? ContentConfigurable)?.preferredViewSize {
        view.frame.size = size
      }
      #if os(iOS)
        scrollView.insertSubview(view, at: index)
      #endif
      component.items.insert(item, at: 0)
    }
  }

  /// Update item at index with new item.
  ///
  /// - parameter item:       The new update view model that you want to update at an index.
  /// - parameter index:      The index of the view model, defaults to 0.
  /// - parameter animation:  A Animation that is used when performing the mutation (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been removed.
  func update(_ item: Item, index: Int, withAnimation animation: Animation = .none, completion: Completion = nil) {
    guard let view = scrollView.subviews[index] as? ContentConfigurable else { return }

    component.items[index] = item
    view.configure(&component.items[index])
  }

  /// Delete item from collection with animation
  ///
  /// - parameter item:       The view model that you want to remove.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  public func delete(_ item: Item, withAnimation animation: Animation = .none, completion: Completion = nil) {
    guard let index = component.items.index(where: { $0 == item })
      else {
        completion?()
        return
    }

    Dispatch.main { [weak self] in
      self?.component.items.remove(at: index)
      self?.scrollView.subviews[index].removeFromSuperview()
    }
  }

  /// Delete items from collection with animation
  ///
  /// - parameter items:      A collection of view models that you want to delete.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  public func delete(_ items: [Item], withAnimation animation: Animation = .none, completion: Completion = nil) {
    let count = component.items.count

    Dispatch.main { [weak self] in
      for (index, _) in items.enumerated() {
        self?.component.items.remove(at: count - index)
        self?.scrollView.subviews[count - index].removeFromSuperview()
      }
    }
  }

  /// Delete item at index with animation
  ///
  /// - parameter index:      The index of the view model that you want to remove.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been removed.
  func delete(_ index: Int, withAnimation animation: Animation = .none, completion: Completion = nil) {
    guard index >= 0 && index <= scrollView.subviews.count else { return }

    component.items.remove(at: index)
    scrollView.subviews[index].removeFromSuperview()
  }

  /// Delete a collection
  ///
  /// - parameter indexes:    An array of indexes that you want to remove.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been removed.
  func delete(_ indexes: [Int], withAnimation animation: Animation = .none, completion: Completion) {
    for (index, _) in component.items.enumerated() {
      guard index >= 0 && index <= scrollView.subviews.count else { return }

      component.items.remove(at: index)
      scrollView.subviews[index].removeFromSuperview()
    }
  }

  /// Reloads a spot only if it changes
  ///
  /// - parameter items:      A collection of Items
  /// - parameter animation:  The animation that should be used (only works for Listable objects)
  /// - parameter completion: A completion closure that is performed when all mutations are performed
  func reload(_ indexes: [Int]? = nil, withAnimation animation: Animation = .none, completion: Completion = nil) { }
}
