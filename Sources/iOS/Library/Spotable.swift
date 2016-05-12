import UIKit
import Brick
import Sugar

/// A class protocol that is used for all components inside of SpotsController
public protocol Spotable: class {

  /// A view registry that is used internally when resolving kind to the corresponding spot.
  static var views: ViewRegistry { get }
  /// The default view type for the spotable object
  static var defaultView: UIView.Type { get set }
  /// The default kind to fall back to if the view model kind does not exist when trying to display the spotable item
  static var defaultKind: StringConvertible { get }

  weak var spotsDelegate: SpotsDelegate? { get set }

  var index: Int { get set }
  var component: Component { get set }
  var configure: (SpotConfigurable -> Void)? { get set }
  var stateCache: SpotCache? { get }

  init(component: Component)

  /// Setup Spotable object with size
  func setup(size: CGSize)
  /// Append view model to a Spotable object
  func append(item: ViewModel, withAnimation animation: SpotsAnimation, completion: Completion)
  /// Append a collection of view models to Spotable object
  func append(items: [ViewModel], withAnimation animation: SpotsAnimation, completion: Completion)
  /// Prepend view models to a Spotable object
  func prepend(items: [ViewModel], withAnimation animation: SpotsAnimation, completion: Completion)
  /// Insert view model to a Spotable object
  func insert(item: ViewModel, index: Int, withAnimation animation: SpotsAnimation, completion: Completion)
  /// Update view model to a Spotable object
  func update(item: ViewModel, index: Int, withAnimation animation: SpotsAnimation, completion: Completion)
  /// Delete view model from a Spotable object
  func delete(item: ViewModel, withAnimation animation: SpotsAnimation, completion: Completion)
  /// Delete a collection of view models from a Spotable object
  func delete(item: [ViewModel], withAnimation animation: SpotsAnimation, completion: Completion)
  /// Delete view model at index with animation from a Spotable object
  func delete(index: Int, withAnimation animation: SpotsAnimation, completion: Completion)
  /// Delete view model indexes with animation from a Spotable object
  func delete(indexes: [Int], withAnimation animation: SpotsAnimation, completion: Completion)
  /// Reload view model indexes with animation in a Spotable object
  func reload(indexes: [Int]?, withAnimation animation: SpotsAnimation, completion: Completion)
  /// Return a Spotable object as a UIScrollView
  func render() -> UIScrollView
  /// Layout Spotable object using size
  func layout(size: CGSize)
  /// Perform internal preperations for a Spotable object
  func prepare()
  /// Scroll to view model using predicate
  func scrollTo(@noescape includeElement: (ViewModel) -> Bool) -> CGFloat
}

public extension Spotable {

  /// A collection of view models
  var items: [ViewModel] {
    set(items) { component.items = items }
    get { return component.items }
  }

  /// Return a dictionary representation of Spotable object
  public var dictionary: JSONDictionary {
    get {
      return component.dictionary
    }
  }

  /**
   - Parameter spot: Spotable
   - Parameter register: A closure containing class type and reuse identifer
   */
  func registerAndPrepare(@noescape register: (classType: UIView.Type, withIdentifier: String) -> Void) {
    if component.kind.isEmpty { component.kind = Self.defaultKind.string }

    Self.views.storage.forEach { (reuseIdentifier: String, classType: UIView.Type) in
      register(classType: classType, withIdentifier: reuseIdentifier)
    }

    if !Self.views.storage.keys.contains(component.kind) {
      register(classType: Self.defaultView, withIdentifier: component.kind)
    }

    var cached: UIView?
    component.items.enumerate().forEach { (index: Int, item: ViewModel) in
      prepareItem(item, index: index, cached: &cached)
    }
    cached = nil
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
   Reloads spot only if it has changes
   - Parameter items: An array of view models
   - Parameter animated: Perform reload animation
   */
  public func reloadIfNeeded(items: [ViewModel], withAnimation animation: SpotsAnimation = .Automatic) {
    guard !(self.items == items) else {
      cache()
      return
    }

    self.items = items
    reload(nil, withAnimation: animation) {
      self.cache()
    }
  }

  /**
   Caches the current state of the spot
  */
  public func cache() {
    stateCache?.save(dictionary)
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
  public func prepareItem(item: ViewModel, index: Int, inout cached: UIView?) {
    cachedViewFor(item, cache: &cached)

    component.items[index].index = index

    guard let view = cached as? SpotConfigurable else { return }

    view.configure(&component.items[index])

    if component.items[index].size.height == 0 {
      component.items[index].size.height = view.size.height
    }
  }

  /**
   Cache view for item kind

   - Parameter item: A view model
   - Parameter cached: An optional UIView, used to reduce the amount of different reusable views that should be prepared.
   */
  func cachedViewFor(item: ViewModel, inout cache: UIView?) {
    let reuseIdentifer = item.kind.isPresent ? item.kind : component.kind
    let componentClass = self.dynamicType.views.storage[reuseIdentifer] ?? self.dynamicType.defaultView

    if cache?.isKindOfClass(componentClass) == false { cache = nil }
    if cache == nil { cache = componentClass.init() }
  }

  /**
   Get reuseidentifier for the item at index path, it checks if the view model kind is registered inside of the ViewRegistry, otherwise it falls back to trying to resolve the component.kind to get the reuse identifier. As a last result, it will return the default kind for the Spotable kind.

   - Parameter indexPath: The index path of the item you are trying to resolve
   */
  func reuseIdentifierForItem(indexPath: NSIndexPath) -> String {
    let viewModel = item(indexPath)
    if self.dynamicType.views.storage[viewModel.kind] != nil {
      return viewModel.kind
    } else if self.dynamicType.views.storage[component.kind] != nil {
      return component.kind
    } else {
      return self.dynamicType.defaultKind.string
    }
  }
}
