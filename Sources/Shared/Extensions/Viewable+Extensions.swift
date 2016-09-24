#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif

import Brick

/// A Spotable extension for Viewable objects
public extension Spotable where Self : Viewable {

  /**
   - returns: UIScrollView: A UIScrollView container for your view
   */
  func render() -> ScrollView {
    return scrollView
  }

  /**
   - parameter size: A CGSize to set the size of the view
   */
  func layout(size: CGSize) {
    render().frame.size = size
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

  private func prepareSpot<T: Viewable>(spot: T) {
    if component.kind.isEmpty { component.kind = "view" }

    component.items.forEach { (item: ViewModel) in
      if case let Registry.Item.classType(classType)? = T.views.storage[item.kind]
        where T.views.storage.keys.contains(item.kind) {
        let view = classType.init()

        if let spotConfigurable = view as? SpotConfigurable {
          spotConfigurable.configure(&component.items[index])
          view.frame.size = spotConfigurable.size
        }

        scrollView.addSubview(view)
      }
    }
  }

  func setup(size: CGSize) {
    let height = component.items.reduce(0, combine: { $0 + $1.size.height })
    let size = CGSize(width: size.width, height: height)
    render().frame.size = size
    #if os(iOS)
      scrollView.contentSize = size
    #endif

    component.items.enumerate().forEach {
      component.items[$0.index].size.width = size.width
      scrollView.subviews[$0.index].frame.size.width = size.width
    }
  }

  /**
   - parameter item: The view model that you want to append
   - parameter withAnimation: The animation that should be used (currently not in use)
   - parameter completion: Completion
   */
  func append(item: ViewModel, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    let dynamic = self.dynamicType

    guard case let Registry.Item.classType(classType)? = dynamic.views.storage[item.kind]
      where dynamic.views.storage.keys.contains(item.kind) else { return }

    let view = classType.init()
    (view as? SpotConfigurable)?.configure(&component.items[index])
    if let size = (view as? SpotConfigurable)?.size {
      view.frame.size = size
    }


    scrollView.addSubview(view)
    component.items.append(item)
  }

  /**
   - parameter items: A collection of view models that you want to insert
   - parameter withAnimation: The animation that should be used (currently not in use)
   - parameter completion: Completion
   */
  func append(items: [ViewModel], withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    for item in items {
      let dynamic = self.dynamicType

      guard case let Registry.Item.classType(classType)? = dynamic.views.storage[item.kind]
        where dynamic.views.storage.keys.contains(item.kind) else { return }

      let view = classType.init()
      (view as? SpotConfigurable)?.configure(&component.items[index])
      if let size = (view as? SpotConfigurable)?.size {
        view.frame.size = size
      }

      scrollView.addSubview(view)
      component.items.append(item)
    }
  }

  /**
   - parameter item: The view model that you want to insert
   - parameter index: The index where the new ViewModel should be inserted
   - parameter animation: A SpotAnimation struct that determines which animation that should be used to perform the update
   - parameter completion: Completion
   */
  func insert(item: ViewModel, index: Int, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    let dynamic = self.dynamicType

    guard case let Registry.Item.classType(classType)? = dynamic.views.storage[item.kind]
      where dynamic.views.storage.keys.contains(item.kind) else { return }

    let view = classType.init()
    (view as? SpotConfigurable)?.configure(&component.items[index])
    if let size = (view as? SpotConfigurable)?.size {
      view.frame.size = size
    }
    #if os(iOS)
      scrollView.insertSubview(view, atIndex: index)
    #endif
    component.items.insert(item, atIndex: index)
  }

  /**
   - parameter items: A collection of view model that you want to prepend
   - parameter animation:  A SpotAnimation that is used when performing the mutation (currently not in use)
   - parameter completion: A completion closure that is executed in the main queue
   */
  func prepend(items: [ViewModel], withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    component.items.insertContentsOf(items, at: 0)

    for item in items.reverse() {
      let dynamic = self.dynamicType

      guard case let Registry.Item.classType(classType)? = dynamic.views.storage[item.kind]
        where dynamic.views.storage.keys.contains(item.kind) else { return }

      let view = classType.init()
      (view as? SpotConfigurable)?.configure(&component.items[index])
      if let size = (view as? SpotConfigurable)?.size {
        view.frame.size = size
      }
      #if os(iOS)
        scrollView.insertSubview(view, atIndex: index)
      #endif
      component.items.insert(item, atIndex: 0)
    }
  }

  func update(item: ViewModel, index: Int, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    guard let view = scrollView.subviews[index] as? SpotConfigurable else { return }

    component.items[index] = item
    view.configure(&component.items[index])
  }

  /**
   - parameter item: The view model that you want to remove
   - parameter withAnimation: The animation that should be used (currently not in use)
   - parameter completion: A completion closure that is executed in the main queue
   */
  public func delete(item: ViewModel, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    guard let index = component.items.indexOf({ $0 == item })
      else { completion?(); return }

    Dispatch.mainQueue { [weak self] in
      self?.component.items.removeAtIndex(index)
      self?.scrollView.subviews[index].removeFromSuperview()
    }
  }

  /**
   - parameter items: A collection of view models that you want to delete
   - parameter withAnimation: The animation that should be used (currently not in use)
   - parameter completion: A completion closure that is executed in the main queue
   */
  public func delete(items: [ViewModel], withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    let count = component.items.count

    Dispatch.mainQueue { [weak self] in
      for (index, _) in items.enumerate() {
        self?.component.items.removeAtIndex(count - index)
        self?.scrollView.subviews[count - index].removeFromSuperview()
      }
    }
  }

  /**
   - parameter index: The index of the view model that you want to remove
   - parameter withAnimation: The animation that should be used (currently not in use)
   - parameter completion: A completion closure that is executed in the main queue when the view model has been removed
   */
  func delete(index: Int, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    guard index >= 0 && index <= scrollView.subviews.count else { return }

    component.items.removeAtIndex(index)
    scrollView.subviews[index].removeFromSuperview()
  }

  /**
   - parameter indexes: An array of indexes that you want to remove
   - parameter withAnimation: The animation that should be used (currently not in use)
   - parameter completion: A completion closure that is executed in the main queue when the view model has been removed
   */
  func delete(indexes: [Int], withAnimation animation: SpotsAnimation = .None, completion: Completion) {
    for (index, _) in component.items.enumerate() {
      guard index >= 0 && index <= scrollView.subviews.count else { return }

      component.items.removeAtIndex(index)
      scrollView.subviews[index].removeFromSuperview()
    }
  }

  func reload(indexes: [Int]? = nil, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) { }
}
