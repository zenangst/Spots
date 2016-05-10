import UIKit
import Sugar
import Brick

/// Viewable is a protocol for Spots that are based on UIScrollView
public protocol Viewable: Spotable {
  var scrollView: UIScrollView { get }
}

public extension Spotable where Self : Viewable {

  func render() -> UIScrollView {
    return scrollView
  }

  func layout(size: CGSize) {
    render().frame.size = size
    scrollView.contentSize = size
  }

  public func prepare() {
    prepareSpot(self)
  }

  private func prepareSpot<T: Spotable>(spot: T) {
    if component.kind.isEmpty { component.kind = "view" }

    component.items.forEach {
      if T.views.storage.keys.contains($0.kind) {
        let viewClass = T.views.storage[$0.kind] ?? T.defaultView
        let view = viewClass.init().then {
          ($0 as? SpotConfigurable)?.configure(&component.items[index])
          guard let size = ($0 as? SpotConfigurable)?.size else { return }
          $0.frame.size = size
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

  func update(item: ViewModel, index: Int, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    guard let view = scrollView.subviews[index] as? SpotConfigurable else { return }

    component.items[index] = item
    view.configure(&component.items[index])
  }

  func delete(index: Int, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    guard index >= 0 && index <= scrollView.subviews.count else { return }

    component.items.removeAtIndex(index)
    scrollView.subviews[index].removeFromSuperview()
  }

  func delete(indexes: [Int], withAnimation animation: SpotsAnimation = .None, completion: Completion) {
    for (index, _) in component.items.enumerate() {
      guard index >= 0 && index <= scrollView.subviews.count else { return }

      component.items.removeAtIndex(index)
      scrollView.subviews[index].removeFromSuperview()
    }
  }

  func reload(indexes: [Int]? = nil, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) { }
}
