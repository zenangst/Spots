#if os(OSX)
  import Foundation
#else
  import UIKit
#endif

// MARK: - Component extension
public extension Component {

  /// Return a dictionary representation of Component object
  public var dictionary: [String : Any] {
    return model.dictionary
  }

  /// A computed CGFloat of the total height of all items inside of a component
  public var computedHeight: CGFloat {
    guard model.layout?.dynamicHeight == true else {
      return self.view.frame.height
    }

    var height: CGFloat = 0

    if tableView != nil {
      #if !os(OSX)
        let superViewHeight = self.view.superview?.frame.size.height ?? UIScreen.main.bounds.height
      #endif

      for item in model.items {
        height += item.size.height

        #if !os(OSX)
          /// tvOS adds spacing between cells (it seems to be locked to 14 pixels in height).
          #if os(tvOS)
            if model.kind == .list {
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
        if model.kind == .list {
          height += 28
        }
      #endif
    } else if let collectionView = collectionView {
      #if os(macOS)
      if let collectionViewLayout = collectionView.collectionViewLayout {
        height = collectionViewLayout.collectionViewContentSize.height
      }
      #else
        if let collectionViewLayout = collectionView.collectionViewLayout as? FlowLayout {
          switch collectionViewLayout.scrollDirection {
          case .horizontal:
            if let firstItem = item(at: 0), firstItem.size.height > collectionViewLayout.collectionViewContentSize.height {
              height = firstItem.size.height + collectionViewLayout.sectionInset.top + collectionViewLayout.sectionInset.bottom
            } else {
              height = collectionViewLayout.collectionViewContentSize.height
            }
          case .vertical:
            height = collectionView.collectionViewLayout.collectionViewContentSize.height
          }
        }
      #endif
    }

    return height
  }

  func configureClosureDidChange() {
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
  func prepareItems(clean: Bool = true) {
    model.items = prepare(items: model.items, clean: clean)
  }

  func prepare(items: [Item], clean: Bool) -> [Item] {
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

      if let configuredItem = configure(item: item, at: index, usesViewSize: true, clean: clean) {
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
    var updatedItems = model.items

    updatedItems.enumerated().forEach {
      updatedItems[$0.offset].index = $0.offset
    }

    model.items = updatedItems
    completion?()
  }

  /// Caches the current state of the component
  public func cache() {
    stateCache?.save(dictionary)
  }

  /// Prepares a view model item before being used by the UI component
  ///
  /// - parameter index:        The index of the view model
  /// - parameter usesViewSize: A boolean value to determine if the view uses the views height
  public func configureItem(at index: Int, usesViewSize: Bool = false, clean: Bool = true) {
    guard let item = item(at: index),
      let configuredItem = configure(item: item, at: index, usesViewSize: usesViewSize, clean: clean)
      else {
        return
    }

    model.items[index] = configuredItem
  }

  func configure(item: Item, at index: Int, usesViewSize: Bool = false, clean: Bool) -> Item? {
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

      prepare(kind: kind, view: view as Any, item: &item, clean: clean)
    #else
      if fullWidth == 0.0 {
        fullWidth = view.superview?.frame.size.width ?? view.frame.size.width
      }

      let kind = identifier(at: index)

      if kind.contains(CompositeComponent.identifier) {
        let composite: Composable
        if kind.contains("list") {
          composite = ListComposite()
        } else {
          composite = GridComposite()
        }

        composite.contentView.frame.size = view.frame.size
        prepare(composable: composite, item: &item, clean: clean)
      } else {
        if let (_, resolvedView) = Configuration.views.make(kind, parentFrame: self.view.frame) {
          prepare(kind: kind, view: resolvedView as Any, item: &item, clean: clean)
        } else {
          return nil
        }
      }
    #endif

    return item
  }

  func prepare(kind: String, view: Any, item: inout Item, clean: Bool) {
    switch view {
    case let view as Composable:
      prepare(composable: view, item: &item, clean: clean)
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
  func prepare(composable: Composable, item: inout Item, clean: Bool) {
    var height: CGFloat = 0.0

    if clean {
      compositeComponents.filter({ $0.itemIndex == item.index }).forEach {
        $0.component.view.removeFromSuperview()

        if let index = compositeComponents.index(of: $0) {
          compositeComponents.remove(at: index)
        }
      }
    }

    let components: [Component] = Parser.parse(item)
    let size = view.frame.size
    let width = size.width

    components.forEach { component in
      let compositeSpot = CompositeComponent(component: component,
                                             parentComponent: self,
                                             itemIndex: item.index)

      compositeSpot.component.setup(with: size)
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
  /// - returns: A string identifier for the view, defaults to the `defaultIdentifier` on the component.
  public func identifier(at index: Int) -> String {
    guard let userInterface = userInterface else {
      assertionFailure("Unable to resolve userinterface.")
      return ""
    }

    if let item = item(at: index), item.kind.contains(CompositeComponent.identifier) {
      return type(of: userInterface).compositeIdentifier
    } else if let item = item(at: index), Configuration.views.storage[item.kind] != nil {
      return item.kind
    } else {
      return Configuration.views.defaultIdentifier
    }
  }

  /// Get offset of item
  ///
  /// - Parameter includeElement: A predicate closure to determine the offset of the item.
  /// - Returns: The offset based of the model data.
  public func itemOffset(_ includeElement: (Item) -> Bool) -> CGFloat {
    guard let item = model.items.filter(includeElement).first else {
      return 0.0
    }

    let offset: CGFloat
    if model.interaction.scrollDirection == .horizontal {
      offset = model.items[0..<item.index].reduce(0, { $0 + $1.size.width })
    } else {
      offset = model.items[0..<item.index].reduce(0, { $0 + $1.size.height })
    }

    return offset
  }

  /// Update height and refresh indexes for the component.
  ///
  /// - parameter completion: A completion closure that will be run when the computations are complete.
  public func sanitize(completion: Completion = nil) {
    updateHeight { [weak self] in
      self?.refreshIndexes()
      completion?()
    }
  }

  func configure(with layout: Layout) {}
}
