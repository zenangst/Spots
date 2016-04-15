import UIKit
import Brick

public protocol Spotable: class {

  static var views: ViewRegistry { get }
  static var defaultView: UIView.Type { get set }
  static var defaultKind: String { get }

  weak var spotsDelegate: SpotsDelegate? { get set }

  var index: Int { get set }
  var component: Component { get set }
  var configure: (SpotConfigurable -> Void)? { get set }

  init(component: Component)

  func setup(size: CGSize)
  func append(item: ViewModel, completion: (() -> Void)?)
  func append(items: [ViewModel], completion: (() -> Void)?)
  func prepend(items: [ViewModel], completion: (() -> Void)?)
  func insert(item: ViewModel, index: Int, completion: (() -> Void)?)
  func update(item: ViewModel, index: Int, completion: (() -> Void)?)
  func delete(index: Int, completion: (() -> Void)?)
  func delete(indexes: [Int], completion: (() -> Void)?)
  func reload(indexes: [Int]?, completion: (() -> Void)?)
  func render() -> UIScrollView
  func layout(size: CGSize)
  func prepare()
  func scrollTo(@noescape includeElement: (ViewModel) -> Bool) -> CGFloat
}

public extension Spotable {

  var items: [ViewModel] {
    set(items) { component.items = items }
    get { return component.items }
  }

  /**
   - Parameter spot: Spotable
   */
  func registerAndPrepare<T: Spotable>(spot: T, @noescape register: (classType: UIView.Type, withIdentifier: String) -> Void) {
    if component.kind.isEmpty { component.kind = spot.dynamicType.defaultKind }

    for (reuseIdentifier, classType) in T.views.storage {
      register(classType: classType, withIdentifier: reuseIdentifier)
    }

    if !T.views.storage.keys.contains(component.kind) {
      register(classType: T.defaultView, withIdentifier: component.kind)
    }

    var cached: UIView?
    for (index, item) in component.items.enumerate() {
      prepareItem(item, index: index, spot: self, cached: &cached)
    }
  }

  /**
   - Parameter index: The index of the item to lookup
   - Returns: A ViewModel at found at the index
   */
  public func item(index: Int) -> ViewModel {
    return component.items[index]
  }

  /**
   - Parameter indexPath: The indexPath of the item to lookup
   - Returns: A ViewModel at found at the index
   */
  public func item(indexPath: NSIndexPath) -> ViewModel {
    return component.items[indexPath.item]
  }

  /**
   - Returns: A CGFloat of the total height of all items inside of a component
   */
  public func spotHeight() -> CGFloat {
    return component.items.reduce(0, combine: { $0 + $1.size.height })
  }

  /**
   Refreshes the indexes of all items within the component
   */
  public func refreshIndexes() {
    items.enumerate().forEach {
      items[$0.index].index = $0.index
    }
  }

  /**
   TODO: We should probably have a look at this method? Seems silly to always return 0.0 😁

   - Parameter includeElement: A filter predicate to find a view model
   - Returns: Always returns 0.0
   */
  public func scrollTo(@noescape includeElement: (ViewModel) -> Bool) -> CGFloat {
    return 0.0
  }

  /**
   Prepares a view model item before being used by the UI component

   - Parameter item: A view model
   - Parameter index: The index of the view model
   - Parameter spot: The spot that should be prepared
   - Parameter cached: An optional UIView, used to reduce the amount of different reusable views that should be prepared.
   */
  public func prepareItem<T: Spotable>(item: ViewModel, index: Int, spot: T, inout cached: UIView?) {
    let reuseIdentifer = item.kind.isPresent ? item.kind : component.kind
    let componentClass = T.views.storage[reuseIdentifer] ?? T.defaultView

    component.items[index].index = index

    if cached?.isKindOfClass(componentClass) == false { cached = nil }
    if cached == nil { cached = componentClass.init() }

    guard let view = cached as? SpotConfigurable else { return }

    view.configure(&component.items[index])

    if component.items[index].size.height == 0 {
      component.items[index].size.height = view.size.height
    }
  }

  func cachedViewFor(item: ViewModel, inout cache: UIView?) {
    let reuseIdentifer = item.kind.isPresent ? item.kind : component.kind
    let componentClass = self.dynamicType.views.storage[reuseIdentifer] ?? self.dynamicType.defaultView

    if cache?.isKindOfClass(componentClass) == false { cache = nil }
    if cache == nil { cache = componentClass.init() }
  }
}
