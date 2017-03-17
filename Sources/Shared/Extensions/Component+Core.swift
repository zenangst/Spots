#if os(OSX)
  import Foundation
#else
  import UIKit
#endif

// MARK: - Component extension
public extension Component {

  /// A computed value for the current index
  public var index: Int {
    return model.index
  }

  public var usesDynamicHeight: Bool {
    get {
      return model.layout?.dynamicHeight ?? true
    }
    set {
      model.layout?.dynamicHeight = newValue
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

    for item in model.items {
      height += item.size.height

      #if !os(OSX)
        /// tvOS adds spacing between cells (it seems to be locked to 14 pixels in height).
        #if os(tvOS)
          if model.kind == ComponentModel.Kind.list.string {
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
      if model.kind == ComponentModel.Kind.list.string {
        height += 28
      }
    #endif

    return height
  }

  #if !os(OSX)
  public func configureClosureDidChange() {
    guard let configure = configure else {
      return
    }

    userInterface?.visibleViews.forEach { view in
      switch view {
      case let view as ItemConfigurable:
        configure(view)
      case let view as Wrappable:
        if let wrappedView = view.wrappedView as? ItemConfigurable {
          configure(wrappedView)
        }
      default:
        break
      }
    }
  }
  #endif

  /// A helper method to return self as a Component type.
  ///
  /// - returns: Self as a Component type
  public var type: Component.Type {
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
    model.items = prepare(items: model.items)
  }

  func prepare(items: [Item]) -> [Item] {
    var preparedItems = items
    var spanWidth: CGFloat?

    if let layout = model.layout, layout.span > 0.0 {
      var componentWidth: CGFloat = view.frame.size.width - CGFloat(layout.inset.left + layout.inset.right)

      #if !os(OSX)
        if view.frame.size.width == 0.0 {
          componentWidth = UIScreen.main.bounds.width - CGFloat(layout.inset.left + layout.inset.right)
        }
      #endif

      spanWidth = (componentWidth / CGFloat(layout.span)) - CGFloat(layout.itemSpacing)
    }

    preparedItems.enumerated().forEach { (index: Int, item: Item) in
      var item = item
      if let spanWidth = spanWidth {
        item.size.width = spanWidth
      }

      if let configuredItem = configure(item: item, at: index, usesViewSize: true) {
        preparedItems[index].index = index
        preparedItems[index] = configuredItem
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
    guard index < model.items.count && index > -1 else {
      return nil
    }

    return model.items[index]
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

  /// Update the height of the UI ComponentModel
  ///
  /// - parameter completion: A completion closure that will be run in the main queue when the size has been updated.
  public func updateHeight(_ completion: Completion = nil) {
    Dispatch.interactive { [weak self] in
      guard let strongSelf = self else {
        Dispatch.main {
          completion?()
        }
        return
      }

      let componentHeight = strongSelf.computedHeight
      Dispatch.main { [weak self] in
        self?.view.frame.size.height = componentHeight
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

  /// Caches the current state of the component
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

    model.items[index] = configuredItem
  }

  func configure(item: Item, at index: Int, usesViewSize: Bool = false) -> Item? {
    var item = item
    item.index = index

    var fullWidth: CGFloat = item.size.width

    #if !os(OSX)
      if fullWidth == 0.0 {
        fullWidth = UIScreen.main.bounds.width
      }

      let kind = identifier(at: index)
      let view: View?

      if let (_, resolvedView) = Configuration.views.make(kind, parentFrame: self.view.bounds) {
        view = resolvedView
      } else {
        return nil
      }

      if let view = view {
        view.frame.size.width = self.view.bounds.width
        prepare(view: view)
      }

      prepare(kind: kind, view: view as Any, item: &item)
    #else
      let componentKind = self

      if fullWidth == 0.0 {
        fullWidth = view.superview?.frame.size.width ?? view.frame.size.width
      }

      switch componentKind {
      case let grid as Gridable:
        var kind = item.kind.isEmpty || type(of: grid).grids.storage[item.kind] == nil
          ? identifier(at: index)
          : item.kind

        if kind == "" {
          kind = type(of: grid).grids.defaultIdentifier
        }

        if let (_, resolvedView) = type(of: grid).grids.make(kind) {
          prepare(kind: kind, view: resolvedView as Any, item: &item)
        } else if let (_, resolvedView) = Configuration.views.make(kind, parentFrame: self.view.frame) {
          prepare(kind: kind, view: resolvedView as Any, item: &item)
        } else {
          return nil
        }
      default:
        let kind = identifier(at: index)
        if let (_, resolvedView) = Self.views.make(kind, parentFrame: self.view.frame) {
          prepare(kind: kind, view: resolvedView as Any, item: &item)
        } else if let (_, resolvedView) = Configuration.views.make(kind, parentFrame: self.view.frame) {
          prepare(kind: kind, view: resolvedView as Any, item: &item)
        } else {
          return nil
        }
      }
    #endif

    return item
  }

  func prepare(kind: String, view: Any, item: inout Item) {
    switch view {
    case let view as Composable:
      prepare(composable: view, item: &item)
    case let view as ItemConfigurable:
      view.configure(&item)
      setFallbackViewSize(to: &item, with: view)
    default:
      break
    }
  }

  #if !os(OSX)
  /// Prepare view frame for item
  ///
  /// - parameter view: The view that is going to be prepared.
  func prepare(view: View) {
    // Set initial size for view
    self.view.frame.size.width = view.frame.size.width

    if let itemConfigurable = view as? ItemConfigurable, view.frame.size.height == 0.0 {
      view.frame.size = itemConfigurable.preferredViewSize
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
  /// - returns: The height for the item based of the composable components
  func prepare(composable: Composable, item: inout Item) {
    var height: CGFloat = 0.0

    compositeComponents.filter({ $0.itemIndex == item.index }).forEach {
      $0.component.view.removeFromSuperview()

      if let index = compositeComponents.index(of: $0) {
        compositeComponents.remove(at: index)
      }
    }

    let components: [Component] = Parser.parse(item)
    let size = view.frame.size
    let width = size.width

    components.forEach { component in
      let compositeSpot = CompositeComponent(component: component,
                                             parentComponent: self,
                                             itemIndex: item.index)

      compositeSpot.component.setup(size)
      compositeSpot.component.model.size = CGSize(
        width: width,
        height: ceil(compositeSpot.component.view.frame.size.height))
      compositeSpot.component.view.layoutIfNeeded()
      compositeSpot.component.view.frame.origin.y = height

      #if !os(OSX)
        /// Disable scrolling for listable objects
        compositeSpot.component.view.isScrollEnabled = !(compositeSpot.component.view is TableView)
      #endif

      compositeSpot.component.view.frame.size.height = compositeSpot.component.view.contentSize.height

      height += compositeSpot.component.view.frame.size.height

      compositeComponents.append(compositeSpot)
    }

    item.size.height = height
  }

  /// Set fallback size to view
  ///
  /// - Parameters:
  ///   - item: The item struct that is being configured.
  ///   - view: The view used for fallback size for the item.
  private func setFallbackViewSize(to item: inout Item, with view: ItemConfigurable) {
    let hasExplicitHeight: Bool = item.size.height == 0.0

    if hasExplicitHeight {
      item.size.height = view.preferredViewSize.height
    }

    if item.size.width == 0.0 {
      item.size.width  = view.preferredViewSize.width
    }

    if let superview = self.view.superview, item.size.width == 0.0 {
      item.size.width = superview.frame.width
    }

    if let view = view as? View, item.size.width == 0.0 {
      item.size.width = view.bounds.width
    }
  }

  /// Get identifier for item at index path
  ///
  /// - parameter indexPath: The index path for the item
  ///
  /// - returns: The identifier string of the item at index path
  func identifier(for indexPath: IndexPath) -> String {
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
  /// - returns: A string identifier for the view, defaults to the `defaultIdentifier` on the Component object.
  public func identifier(at index: Int) -> String {
    if let item = item(at: index), item.kind.contains("composite") {
      if userInterface is TableView {
        return "list-composite"
      } else {
        return "grid-composite"
      }
    } else if let item = item(at: index), type.views.storage[item.kind] != nil {
      return item.kind
    } else if let item = item(at: index), Configuration.views.storage[item.kind] != nil {
      return item.kind
    } else if type.views.defaultItem != nil {
      return type.views.defaultIdentifier
    } else if Configuration.views.defaultItem != nil {
      return Configuration.views.defaultIdentifier
    }

    return type.views.defaultIdentifier
  }

  /// Register and prepare all items in the Component object.
  func registerAndPrepare() {
    register()
    prepareItems()
  }

  /// Update height and refresh indexes for the Component object.
  ///
  /// - parameter completion: A completion closure that will be run when the computations are complete.
  public func sanitize(completion: Completion = nil) {
    updateHeight { [weak self] in
      self?.refreshIndexes()
      completion?()
    }
  }

  /// Register default view for the Component object
  ///
  /// - parameter view: The view type that should be used as the default view
  func registerDefault(view: View.Type) {
    if type(of: self).views.storage[type(of: self).views.defaultIdentifier] == nil {
      type(of: self).views.defaultItem = Registry.Item.classType(view)
    }
  }

  /// Register a composite view for the Component model.
  ///
  /// - parameter view: The view type that should be used as the composite view for the Component object.
  func registerComposite(view: View.Type) {
    if type(of: self).views.composite == nil {
      type(of: self).views.composite = Registry.Item.classType(view)
    }
  }

  /// Register a nib file with identifier on the Component object.
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

  /// Register a default view for the Component object.
  ///
  /// - parameter view: The view type that should be used as the default view for the Component object.
  public static func register(defaultView view: View.Type) {
    self.views.defaultItem = Registry.Item.classType(view)
  }

  public func beforeUpdate() {}
  public func afterUpdate() {}
  func configure(with layout: Layout) {}
}
