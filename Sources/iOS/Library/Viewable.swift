import UIKit
import Sugar
import Brick

/// Viewable is a protocol for Spots that are based on UIScrollView
public protocol Viewable: Spotable {
  var scrollView: UIScrollView { get }
}

/// A Spotable extension for Viewable objects
public extension Spotable where Self : Viewable {

  /**
   - Returns: UIScrollView: A UIScrollView container for your view
   */
  func render() -> UIScrollView {
    return scrollView
  }

  /**
   - Parameter size: A CGSize to set the size of the view
   */
  func layout(size: CGSize) {
    render().frame.size = size
    scrollView.contentSize = size
  }

  /**
   Called when the Gridable object is being prepared, it is required by Spotable
   */
  public func prepare() {
    prepareSpot(self)
  }

  private func prepareSpot<T: Spotable>(spot: T) {
    if component.kind.isEmpty { component.kind = "view" }

    component.items.forEach { (item: ViewModel) in
      if T.views.storage.keys.contains(item.kind) {
        let viewClass = T.views.storage[item.kind] ?? T.defaultView
        let view = viewClass.init()

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
    render().contentSize = size

    component.items.enumerate().forEach {
      component.items[$0.index].size.width = size.width
      scrollView.subviews[$0.index].width = size.width
    }
  }

  /**
   - Parameter item: The view model that you want to append
   - Parameter withAnimation: The animation that should be used (currently not in use)
   - Parameter completion: Completion
   */
  func append(item: ViewModel, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    let dynamic = self.dynamicType

    guard dynamic.views.storage.keys.contains(item.kind) else { return }

    let viewClass = dynamic.views.storage[item.kind] ?? dynamic.defaultView
    let view = viewClass.init().then {
      ($0 as? SpotConfigurable)?.configure(&component.items[index])
      guard let size = ($0 as? SpotConfigurable)?.size else { return }
      $0.frame.size = size
    }
    scrollView.addSubview(view)
    component.items.append(item)
  }

  /**
   - Parameter items: A collection of view models that you want to insert
   - Parameter withAnimation: The animation that should be used (currently not in use)
   - Parameter completion: Completion
   */
  func append(items: [ViewModel], withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    for item in items {
      let dynamic = self.dynamicType

      guard dynamic.views.storage.keys.contains(item.kind) else { return }

      let viewClass = dynamic.views.storage[item.kind] ?? dynamic.defaultView
      let view = viewClass.init().then {
        ($0 as? SpotConfigurable)?.configure(&component.items[index])
        guard let size = ($0 as? SpotConfigurable)?.size else { return }
        $0.frame.size = size
      }
      scrollView.addSubview(view)
      component.items.append(item)
    }
  }

  /**
   - Parameter item: The view model that you want to insert
   - Parameter withAnimation: The animation that should be used (currently not in use)
   - Parameter index: The index where the new ViewModel should be inserted
   - Parameter completion: Completion
   */
  func insert(item: ViewModel, index: Int, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    let dynamic = self.dynamicType

    guard dynamic.views.storage.keys.contains(item.kind) else { return }

    let viewClass = dynamic.views.storage[item.kind] ?? dynamic.defaultView
    let view = viewClass.init().then {
      ($0 as? SpotConfigurable)?.configure(&component.items[index])
      guard let size = ($0 as? SpotConfigurable)?.size else { return }
      $0.frame.size = size
    }
    scrollView.insertSubview(view, atIndex: index)
    component.items.insert(item, atIndex: index)
  }

  /**
   - Parameter item: A collection of view model that you want to prepend
   - Parameter animation: The animation that should be used (currently not in use)
   - Parameter completion: A completion closure that is executed in the main queue
   */
  func prepend(items: [ViewModel], withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    component.items.insertContentsOf(items, at: 0)

    for item in items.reverse() {
      let dynamic = self.dynamicType

      guard dynamic.views.storage.keys.contains(item.kind) else { return }

      let viewClass = dynamic.views.storage[item.kind] ?? dynamic.defaultView
      let view = viewClass.init().then {
        ($0 as? SpotConfigurable)?.configure(&component.items[index])
        guard let size = ($0 as? SpotConfigurable)?.size else { return }
        $0.frame.size = size
      }
      scrollView.insertSubview(view, atIndex: 0)
      component.items.insert(item, atIndex: 0)
    }
  }

  func update(item: ViewModel, index: Int, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    guard let view = scrollView.subviews[index] as? SpotConfigurable else { return }

    component.items[index] = item
    view.configure(&component.items[index])
  }

  /**
   - Parameter item: The view model that you want to remove
   - Parameter withAnimation: The animation that should be used (currently not in use)
   - Parameter completion: A completion closure that is executed in the main queue
   */
  public func delete(item: ViewModel, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    guard let index = component.items.indexOf({ $0 == item })
      else { completion?(); return }

    dispatch { [weak self] in
      self?.component.items.removeAtIndex(index)
      self?.scrollView.subviews[index].removeFromSuperview()
    }
  }

  /**
   - Parameter items: A collection of view models that you want to delete
   - Parameter withAnimation: The animation that should be used (currently not in use)
   - Parameter completion: A completion closure that is executed in the main queue
   */
  public func delete(items: [ViewModel], withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    var indexes = [Int]()
    let count = component.items.count

    dispatch { [weak self] in
      for (index, item) in items.enumerate() {
        self?.component.items.removeAtIndex(count - index)
        self?.scrollView.subviews[count - index].removeFromSuperview()
      }
    }
  }

  /**
   - Parameter index: The index of the view model that you want to remove
   - Parameter withAnimation: The animation that should be used (currently not in use)
   - Parameter completion: A completion closure that is executed in the main queue when the view model has been removed
   */
  func delete(index: Int, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    guard index >= 0 && index <= scrollView.subviews.count else { return }

    component.items.removeAtIndex(index)
    scrollView.subviews[index].removeFromSuperview()
  }

  /**
   - Parameter indexes: An array of indexes that you want to remove
   - Parameter withAnimation: The animation that should be used (currently not in use)
   - Parameter completion: A completion closure that is executed in the main queue when the view model has been removed
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
