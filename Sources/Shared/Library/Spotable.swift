#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif

import Brick
import Sugar

/// A class protocol that is used for all components inside of SpotsController
public protocol Spotable: class {

  /// A view registry that is used internally when resolving kind to the corresponding spot.
  static var views: ViewRegistry { get }
  /// The default view type for the spotable object
  static var defaultView: View.Type { get set }
  /// The default kind to fall back to if the view model kind does not exist when trying to display the spotable item
  static var defaultKind: StringConvertible { get }

  /// A SpotsDelegate object
  weak var spotsDelegate: SpotsDelegate? { get set }

  /// The index of a Spotable object
  var index: Int { get set }
  /// The component of a Spotable object
  var component: Component { get set }
  /// A configuration closure for a SpotConfigurable object
  var configure: (SpotConfigurable -> Void)? { get set }
  /// A cache for a Spotable object
  var stateCache: SpotCache? { get }
  /// A SpotAdapter
  var adapter: SpotAdapter? { get }

  #if os(OSX)
    var responder: NSResponder { get }
    var nextResponder: NSResponder? { get set }
  #endif

  /**
   Initialize a Spotable object with a Component

   - Parameter component: The component that the Spotable object should be initialized with
   - Returns: A Spotable object
   */
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
  func render() -> ScrollView
  /// Layout Spotable object using size
  func layout(size: CGSize)
  /// Perform internal preperations for a Spotable object
  func prepare()
  /// Scroll to view model using predicate
  func scrollTo(@noescape includeElement: (ViewModel) -> Bool) -> CGFloat

  func spotHeight() -> CGFloat
  func sizeForItemAt(indexPath: NSIndexPath) -> CGSize

  /**
   Cache view for item kind

   - Parameter item: A view model
   - Parameter cache: An optional UIView, used to reduce the amount of different reusable views that should be prepared.
   */
  func cachedViewFor(item: ViewModel, inout cache: View?)

  #if os(OSX)
  func deselect()
  #endif
}

public extension Spotable {

  /// Append view model to a Spotable object
  func append(item: ViewModel, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.append(item, withAnimation: animation, completion: completion)
  }

  /// Append a collection of view models to Spotable object
  func append(items: [ViewModel], withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.append(items, withAnimation: animation, completion: completion)
  }

  /// Prepend view models to a Spotable object
  func prepend(items: [ViewModel], withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.prepend(items, withAnimation: animation, completion: completion)
  }
  /// Insert view model to a Spotable object
  func insert(item: ViewModel, index: Int, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.insert(item, index: index, withAnimation: animation, completion: completion)
  }
  /// Update view model to a Spotable object
  func update(item: ViewModel, index: Int, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.update(item, index: index, withAnimation: animation, completion: completion)
  }
  /// Delete view model from a Spotable object
  func delete(item: ViewModel, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion) {
    adapter?.delete(item, withAnimation: animation, completion: completion)
  }
  /// Delete a collection of view models from a Spotable object
  func delete(items: [ViewModel], withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.delete(items, withAnimation: animation, completion: completion)
  }
  /// Delete view model at index with animation from a Spotable object
  func delete(index: Int, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.delete(index, withAnimation: animation, completion: completion)
  }
  /// Delete view model indexes with animation from a Spotable object
  func delete(indexes: [Int], withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.delete(indexes, withAnimation: animation, completion: completion)
  }
  /// Reload view model indexes with animation in a Spotable object
  func reload(indexes: [Int]? = nil, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    adapter?.reload(indexes, withAnimation: animation, completion: completion)
  }
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
   A method to register and prepare a ViewModel

   - Parameter register: A closure containing class type and reuse identifer
   */
  func registerAndPrepare(@noescape register: (classType: View.Type, withIdentifier: String) -> Void) {
    if component.kind.isEmpty { component.kind = Self.defaultKind.string }

    Self.views.storage.forEach { (reuseIdentifier: String, classType: View.Type) in
      register(classType: classType, withIdentifier: reuseIdentifier)
    }

    if !Self.views.storage.keys.contains(component.kind) {
      register(classType: Self.defaultView, withIdentifier: component.kind)
    }

    var cached: View?
    component.items.enumerate().forEach { (index: Int, item: ViewModel) in
      prepareItem(item, index: index, cached: &cached)
    }
    cached = nil
  }

  /**
   - Parameter index: The index of the item to lookup
   - Returns: A ViewModel at found at the index
   */
  public func item(index: Int) -> ViewModel? {
    guard index < component.items.count else { return nil }
    return component.items[index]
  }

  /**
   - Parameter indexPath: The indexPath of the item to lookup
   - Returns: A ViewModel at found at the index
   */
  public func item(indexPath: NSIndexPath) -> ViewModel? {
    #if os(OSX)
      return item(indexPath.item)
    #else
      return item(indexPath.row)
    #endif
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

  /**
   Reloads a spot only if it changes

   - Parameter items:     A collection of ViewModels
   - Parameter animation: The animation that should be used (only works for Listable objects)
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
   Reload Spotable object with JSON if contents changed

   - Parameter json:      A JSON dictionary
   - Parameter animation: The animation that should be used (only works for Listable objects)
   */
  public func reloadIfNeeded(json: JSONDictionary, withAnimation animation: SpotsAnimation = .Automatic) {
    let newComponent = Component(json)

    guard component != newComponent else { cache(); return }

    component = newComponent
    reload(nil, withAnimation: animation) { [weak self] in
      self?.cache()
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
   - Parameter cached: An optional UIView, used to reduce the amount of different reusable views that should be prepared.
   */
  public func prepareItem(item: ViewModel, index: Int, inout cached: View?) {
    cachedViewFor(item, cache: &cached)

    component.items[index].index = index

    guard let view = cached as? SpotConfigurable else { return }

    view.configure(&component.items[index])

    if component.items[index].size.height == 0 {
      component.items[index].size.height = view.size.height
    }

    if component.items[index].size.width == 0 {
      component.items[index].size.width = view.size.width
    }
  }

  /**
   Get reuseidentifier for the item at index path.
   It checks if the view model kind is registered inside of the ViewRegistry,
   otherwise it falls back to trying to resolve the component.kind to get the reuse identifier.
   As a last result, it will return the default kind for the Spotable kind.

   - Parameter indexPath: The index path of the item you are trying to resolve
   */
  func reuseIdentifierForItem(indexPath: NSIndexPath) -> String {
    #if os(OSX)
      return reuseIdentifierForItem(indexPath.item)
    #else
      return reuseIdentifierForItem(indexPath.row)
    #endif
  }

  func reuseIdentifierForItem(index: Int) -> String {
    guard let viewModel = item(index) else { return self.dynamicType.defaultKind.string }

    if self.dynamicType.views.storage[viewModel.kind] != nil {
      return viewModel.kind
    } else if self.dynamicType.views.storage[component.kind] != nil {
      return component.kind
    } else {
      return self.dynamicType.defaultKind.string
    }
  }

  /**
   Configure cell at index

   - Parameter index:    The index of the item that should be configured
   - Parameter cellType: The View.Type of the cell
   - Parameter cached:   An optional cache of the SpotConfigurable object
   - Returns: An optional instance of the SpotConfigurable object
   */
  func configure(itemAtIndex index: Int, ofType cellType: View.Type, cached: SpotConfigurable? = nil) -> SpotConfigurable? {
    var instance: SpotConfigurable? = cached

    if instance == nil {
      instance = cellType.init() as? SpotConfigurable
    }

    guard let cell = instance else { return nil }

    component.items[index].index = index
    cell.configure(&component.items[index])

    return cell
  }

  public func sizeForItemAt(indexPath: NSIndexPath) -> CGSize {
    return render().frame.size
  }
}
