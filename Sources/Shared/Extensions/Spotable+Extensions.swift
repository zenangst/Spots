#if os(OSX)
  import Foundation
#else
  import UIKit
#endif

import Brick

// MARK: - Spotable extension
public extension Spotable {

  /// A computed value for the current index
  public var index: Int {
    return component.index
  }

  public var usesDynamicHeight: Bool {
    get {
      return component.layout?.dynamicHeight ?? true
    }
    set {
      component.layout?.dynamicHeight = newValue
    }
  }

  /// A computed CGFloat of the total height of all items inside of a component
  public var computedHeight: CGFloat {
    guard usesDynamicHeight else {
      return self.view.frame.height
    }

    var height: CGFloat = 0
    #if !os(OSX)
      let superViewHeight = self.view.superview?.frame.size.height ?? UIScreen.main.bounds.height
    #endif

    for item in component.items {
      height += item.size.height

      #if !os(OSX)
        /// tvOS adds spacing between cells (it seems to be locked to 14 pixels in height).
        #if os(tvOS)
          if component.kind == Component.Kind.list.string {
            height += 14
          }
        #endif

        if height > superViewHeight {
          height = superViewHeight
          break
        }
      #endif
    }

    /// Add extra height to make room for focus shadow
    #if os(tvOS)
      if component.kind == Component.Kind.list.string {
        height += 28
      }
    #endif

    return height
  }

  /// A helper method to return self as a Spotable type.
  ///
  /// - returns: Self as a Spotable type
  public var type: Spotable.Type {
    return type(of: self)
  }

  /// Resolve a UI component at index with inferred type
  ///
  /// - parameter index: The index of the UI component
  ///
  /// - returns: An optional view of inferred type
  public func ui<T>(at index: Int) -> T? {
    return userInterface?.view(at: index)
  }

  /// Prepare items in component
  func prepareItems() {
    component.items = prepare(items: component.items)
  }

  func prepare(items: [Item]) -> [Item] {
    var preparedItems = items

    preparedItems.enumerated().forEach { (index: Int, item: Item) in

      if let configuredItem = configure(item: item, at: index, usesViewSize: true) {
        preparedItems[index].index = index
        preparedItems[index] = configuredItem
      }

      if let layout = component.layout {
        if layout.span > 0.0 {
          #if os(OSX)
            if let gridable = self as? Gridable,
              let layout = gridable.layout as? FlowLayout {
              let newWidth = gridable.collectionView.frame.width / CGFloat(componentLayout.span) - layout.sectionInset.left - layout.sectionInset.right

              if newWidth > 0.0 {
                preparedItems[index].size.width = newWidth
              }
            }
          #else
            var spotWidth: CGFloat

            if view.frame.size.width == 0.0 {
              spotWidth = UIScreen.main.bounds.width - CGFloat(layout.inset.left + layout.inset.right)
            } else {
              spotWidth = view.frame.size.width - CGFloat(layout.inset.left + layout.inset.right)
            }

            preparedItems[index].size.width = (spotWidth / CGFloat(layout.span)) - CGFloat(layout.itemSpacing)
          #endif
        }
      }
    }

    return preparedItems
  }

  /// Resolve item at index.
  ///
  /// - parameter index: The index of the item that should be resolved.
  ///
  /// - returns: An optional Item that corresponds to the index.
  public func item(at index: Int) -> Item? {
    guard index < component.items.count && index > -1 else {
      return nil
    }

    return component.items[index]
  }

  /// Resolve item at index path.
  ///
  /// - parameter indexPath: The index path of the item that should be resolved.
  ///
  /// - returns: An optional Item that corresponds to the index path.
  public func item(at indexPath: IndexPath) -> Item? {
    #if os(OSX)
      return item(at: indexPath.item)
    #else
      return item(at: indexPath.row)
    #endif
  }

  /// Update the height of the UI Component
  ///
  /// - parameter completion: A completion closure that will be run in the main queue when the size has been updated.
  public func updateHeight(_ completion: Completion = nil) {
    Dispatch.interactive { [weak self] in
      guard let weakSelf = self else {
        Dispatch.main {
          completion?()
        }
        return
      }

      let spotHeight = weakSelf.computedHeight
      Dispatch.main { [weak self] in
        self?.view.frame.size.height = spotHeight
        completion?()
      }
    }
  }

  /// Refresh indexes for all items to ensure that the indexes are unique and in ascending order.
  public func refreshIndexes(completion: Completion = nil) {
    var updatedItems = items

    updatedItems.enumerated().forEach {
      updatedItems[$0.offset].index = $0.offset
    }

    items = updatedItems
    completion?()
  }

  /// Caches the current state of the spot
  public func cache() {
    stateCache?.save(dictionary)
  }

  /// Scroll to Item matching predicate
  ///
  /// - parameter includeElement: A filter predicate to find a view model
  ///
  /// - returns: A calculate CGFloat based on what the includeElement matches
  public func scrollTo(_ includeElement: (Item) -> Bool) -> CGFloat {
    return 0.0
  }

  /// Prepares a view model item before being used by the UI component
  ///
  /// - parameter index:        The index of the view model
  /// - parameter usesViewSize: A boolean value to determine if the view uses the views height
  public func configureItem(at index: Int, usesViewSize: Bool = false) {
    guard let item = item(at: index),
      let configuredItem = configure(item: item, at: index, usesViewSize: usesViewSize)
      else {
        return
    }

    component.items[index] = configuredItem
  }

  func configure(item: Item, at index: Int, usesViewSize: Bool = false) -> Item? {
    var item = item
    item.index = index

    let fullWidth: CGFloat
    let kind: String

    #if !os(OSX)
      fullWidth = UIScreen.main.bounds.width
      kind = identifier(at: index)

      let view: View?

      if let (_, resolvedView) = Self.views.make(kind) {
        view = resolvedView
      } else if let (_, resolvedView) = Configuration.views.make(kind) {
        view = resolvedView
      } else {
        return nil
      }

      if let view = view {
        prepare(view: view)
      }

      prepare(kind: kind, view: view as Any, item: &item)
    #else
      let spotableKind = self
      fullWidth = view.superview?.frame.size.width ?? view.frame.size.width

      switch spotableKind {
      case let spotableKind as Gridable:
        kind = item.kind.isEmpty || type(of: spotableKind).grids.storage[item.kind] == nil
          ? type(of: spotableKind).grids.defaultIdentifier
          : item.kind

        guard let (_, view) = type(of: spotableKind).grids.make(kind) else {
          return nil
        }

        prepare(kind: kind, view: view as Any, item: &item)
      case let spotableKind as Listable:
        kind = item.kind.isEmpty || type(of: spotableKind).views.storage[item.kind] == nil
          ? type(of: spotableKind).views.defaultIdentifier
          : item.kind

        guard let (_, view) = Self.views.make(kind) else {
          return nil
        }

        prepare(kind: kind, view: view as Any, item: &item)
      default: break
      }
    #endif

    if let layout = component.layout, index < component.items.count && index > -1 &&
      self is Gridable &&
      (layout.span > 0.0 || item.size.width == 0) && fullWidth > 0.0 {
      item.size.width = fullWidth / CGFloat(layout.span)
    }

    return item
  }

  func prepare(kind: String, view: Any, item: inout Item) {
    switch view {
    case let view as Composable:
      prepare(composable: view, item: &item)
    case let view as SpotConfigurable:
      view.configure(&item)
      setFallbackViewSize(to: &item, with: view)
    default: break
    }
  }

  #if !os(OSX)
  /// Prepare view frame for item
  ///
  /// - parameter view: The view that is going to be prepared.
  func prepare(view: View) {
    // Set initial size for view
    view.frame.size.width = view.frame.size.width

    if let spotConfigurable = view as? SpotConfigurable, view.frame.size.height == 0.0 {
      view.frame.size = spotConfigurable.preferredViewSize
    }

    if view.frame.size.width == 0.0 {
      view.frame.size.width = UIScreen.main.bounds.size.width
    }

    (view as? UITableViewCell)?.contentView.frame = view.bounds
    (view as? UICollectionViewCell)?.contentView.frame = view.bounds
  }
  #endif

  /// Prepares a composable view and returns the height for the item
  ///
  /// - parameter composable:        A composable object
  /// - parameter usesViewSize:      A boolean value to determine if the view uses the views height
  ///
  /// - returns: The height for the item based of the composable spots
  func prepare(composable: Composable, item: inout Item) {
    var height: CGFloat = 0.0

    compositeSpots.filter({ $0.itemIndex == item.index }).forEach {
      $0.spot.view.removeFromSuperview()

      if let index = compositeSpots.index(of: $0) {
        compositeSpots.remove(at: index)
      }
    }

    let spots: [Spotable] = Parser.parse(item)
    let size = view.frame.size
    let width = size.width

    spots.forEach { spot in
      let compositeSpot = CompositeSpot(spot: spot,
                                        parentSpot: self,
                                        itemIndex: item.index)

      compositeSpot.spot.setup(size)
      compositeSpot.spot.component.size = CGSize(
        width: width,
        height: ceil(compositeSpot.spot.view.frame.size.height))
      compositeSpot.spot.layout(size)
      compositeSpot.spot.view.layoutIfNeeded()
      compositeSpot.spot.view.frame.origin.y = height

      #if !os(OSX)
        /// Disable scrolling for listable objects
        compositeSpot.spot.view.isScrollEnabled = !(compositeSpot.spot is Listable)
      #endif

      compositeSpot.spot.view.frame.size.height = compositeSpot.spot.view.contentSize.height

      height += compositeSpot.spot.view.frame.size.height

      compositeSpots.append(compositeSpot)
    }

    item.size.height = height
  }

  /// Set fallback size to view
  ///
  /// - Parameters:
  ///   - item: The item struct that is being configured.
  ///   - view: The view used for fallback size for the item.
  private func setFallbackViewSize(to item: inout Item, with view: SpotConfigurable) {
    if item.size.height == 0.0 {
      item.size.height = view.preferredViewSize.height
    }

    if item.size.width  == 0.0 {
      item.size.width  = view.preferredViewSize.width
    }

    if let superview = self.view.superview, item.size.width == 0.0 {
      item.size.width = superview.frame.width
    }

    if let view = view as? View, item.size.width == 0.0 {
      item.size.width = view.bounds.width
    }
  }

  /// Update and return the size for the item at index path.
  ///
  /// - parameter indexPath: indexPath: An NSIndexPath.
  ///
  /// - returns: CGSize of the item at index path.
  public func sizeForItem(at indexPath: IndexPath) -> CGSize {
    return view.frame.size
  }

  /// Get identifier for item at index path
  ///
  /// - parameter indexPath: The index path for the item
  ///
  /// - returns: The identifier string of the item at index path
  func identifier(at indexPath: IndexPath) -> String {
    #if os(OSX)
      return identifier(at: indexPath.item)
    #else
      return identifier(at: indexPath.row)
    #endif
  }

  /// Lookup identifier at index.
  ///
  /// - parameter index: The index of the item that needs resolving.
  ///
  /// - returns: A string identifier for the view, defaults to the `defaultIdentifier` on the Spotable object.
  public func identifier(at index: Int) -> String {
    if let item = item(at: index), type.views.storage[item.kind] != nil {
      return item.kind
    } else if let item = item(at: index), Configuration.views.storage[item.kind] != nil {
      return item.kind
    } else {
      return type.views.defaultIdentifier
    }
  }

  /// Register and prepare all items in the Spotable object.
  func registerAndPrepare() {
    register()
    prepareItems()
  }

  /// Update height and refresh indexes for the Spotable object.
  ///
  /// - parameter completion: A completion closure that will be run when the computations are complete.
  public func sanitize(completion: Completion = nil) {
    updateHeight { [weak self] in
      self?.refreshIndexes()
      completion?()
    }
  }

  /// Register default view for the Spotable object
  ///
  /// - parameter view: The view type that should be used as the default view
  func registerDefault(view: View.Type) {
    if type(of: self).views.storage[type(of: self).views.defaultIdentifier] == nil {
      type(of: self).views.defaultItem = Registry.Item.classType(view)
    }
  }

  /// Register a composite view for the Spotable component.
  ///
  /// - parameter view: The view type that should be used as the composite view for the Spotable object.
  func registerComposite(view: View.Type) {
    if type(of: self).views.composite == nil {
      type(of: self).views.composite = Registry.Item.classType(view)
    }
  }

  /// Register a nib file with identifier on the Spotable object.
  ///
  /// - parameter nib:        A Nib file that should be used for identifier
  /// - parameter identifier: A StringConvertible identifier for the registered nib.
  public static func register(nib: Nib, identifier: StringConvertible) {
    self.views.storage[identifier.string] = Registry.Item.nib(nib)
  }

  /// Register a view with an identifier
  ///
  /// - parameter view:       The view type that should be registered with an identifier.
  /// - parameter identifier: A StringConvertible identifier for the registered view type.
  public static func register(view: View.Type, identifier: StringConvertible) {
    self.views.storage[identifier.string] = Registry.Item.classType(view)
  }

  /// Register a default view for the Spotable object.
  ///
  /// - parameter view: The view type that should be used as the default view for the Spotable object.
  public static func register(defaultView view: View.Type) {
    self.views.defaultItem = Registry.Item.classType(view)
  }

  public func beforeUpdate() {}
  public func afterUpdate() {}
}
