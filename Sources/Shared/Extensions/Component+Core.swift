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

          height += headerView?.frame.size.height ?? 0
          height += footerView?.frame.size.height ?? 0
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

  public func prepareItems(recreateComposites: Bool = true) {
    manager.itemManager.prepareItems(component: self, recreateComposites: recreateComposites)
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
    Dispatch.main { [weak self] in
      guard let `self` = self else {
        completion?()
        return
      }

      let componentHeight = self.computedHeight
      self.view.frame.size.height = componentHeight
      completion?()
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
  public func updateHeightAndIndexes(completion: Completion = nil) {
    updateHeight { [weak self] in
      self?.refreshIndexes(completion: completion)
    }
  }

  func configure(with layout: Layout) {}
}
