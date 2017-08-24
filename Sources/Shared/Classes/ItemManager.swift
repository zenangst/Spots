#if os(macOS)
  import Cocoa
#else
  import UIKit
#endif

public class ItemManager {

  /// Calculate the span width for an item inside of a `Component`.
  /// Span width is the amount of spaces that an `Item` will get inside of a `Component`
  /// that uses `span`. If a `Component` has a `span` of three, it will take the width
  /// of the `Component` (minus insets) and divide it by three. And finally remove `itemSpacing`
  /// as that should not go into the final items size.
  ///
  /// - Parameter component: The `Component` that the function will use as base for the calculation.
  /// - Returns: Returns the new `Item` width based of the `Component` width, if the `Component` does
  ///            not rely on `span`, it will return `nil`.
  func calculateSpanWidth(for component: Component) -> CGFloat? {
    guard component.model.layout.span > 0.0 else {
      return nil
    }

    let inset = CGFloat(component.model.layout.inset.left + component.model.layout.inset.right)
    let componentWidth: CGFloat = component.view.frame.size.width - inset
    return max((componentWidth / CGFloat(component.model.layout.span)) - CGFloat(component.model.layout.itemSpacing), 0)
  }

  func prepareItems(component: Component, recreateComposites: Bool = true) {
    component.model.items = prepare(component: component, items: component.model.items, recreateComposites: recreateComposites)
    Configuration.views.purge()
  }

  func prepare(component: Component, items: [Item], recreateComposites: Bool) -> [Item] {
    var preparedItems = items
    let spanWidth: CGFloat? = calculateSpanWidth(for: component)
    let shouldAdjustHeight = component.model.kind == .carousel
    var largestHeight: CGFloat = 0.0

    preparedItems.enumerated().forEach { (index: Int, item: Item) in
      var item = item
      if let spanWidth = spanWidth {
        item.size.width = spanWidth
      }

      if let configuredItem = configure(component: component, item: item, at: index, usesViewSize: true, recreateComposites: recreateComposites) {
        preparedItems[index].index = index
        preparedItems[index] = configuredItem
      }

      if shouldAdjustHeight && preparedItems[index].size.height > largestHeight {
        largestHeight = preparedItems[index].size.height
      }
    }

    if shouldAdjustHeight {
      for element in preparedItems.indices {
        preparedItems[element].size.height = largestHeight
      }
    }

    return preparedItems
  }

  /// Configure item at index path inside of a component.
  ///
  /// - Parameters:
  ///   - index: The index of the item.
  ///   - component: The component that the item belongs to.
  ///   - usesViewSize: Determines if the views frame should be used when preparing the item.
  ///   - recreateComposites: Determines if composite components should be reconstructed.
  public func configureItem(at index: Int, component: Component, usesViewSize: Bool = false, recreateComposites: Bool = true) {
    guard let item = component.item(at: index),
      var configuredItem = configure(component: component, item: item, at: index, usesViewSize: usesViewSize, recreateComposites: recreateComposites)
      else {
        return
    }

    if let spanWidth = calculateSpanWidth(for: component) {
      configuredItem.size.width = spanWidth
    }

    component.model.items[index] = configuredItem

    guard component.model.kind == .carousel else {
      return
    }

    if let largestHeight: CGFloat = component.model.items.sorted(by: { $0.size.height > $1.size.height }).first?.size.height {
      for element in component.model.items.indices.enumerated() {
        component.model.items[element.offset].size.height = largestHeight
      }
    }
  }

  func configure(component: Component, item: Item, at index: Int, usesViewSize: Bool = false, recreateComposites: Bool) -> Item? {
    var item = item
    item.index = index

    var fullWidth: CGFloat = item.size.width
    let kind = component.identifier(at: index)

    #if !os(OSX)
      if fullWidth == 0.0 {
        fullWidth = UIScreen.main.bounds.width
      }

      let view: View?

      if let resolvedView = Configuration.views.make(kind, parentFrame: component.view.bounds, useCache: true)?.view {
        view = resolvedView
      } else {
        return nil
      }

      if let view = view {
        view.frame.size.width = component.view.bounds.width
        prepare(component: component, item: item, view: view)
      }

      prepare(component: component, kind: kind, view: view as Any, item: &item, recreateComposites: recreateComposites)
    #else
      if fullWidth == 0.0 {
        fullWidth = component.view.superview?.frame.size.width ?? component.view.frame.size.width
      }

      if kind.contains(CompositeComponent.identifier) {
        let wrappable: Wrappable
        if kind.contains("list") {
          wrappable = ListWrapper()
        } else {
          wrappable = GridWrapper()
        }

        prepare(component: component, kind: kind, view: wrappable as Any, item: &item, recreateComposites: recreateComposites)
      } else {
        if let resolvedView = Configuration.views.make(kind, parentFrame: component.view.frame, useCache: true)?.view {
          prepare(component: component, kind: kind, view: resolvedView as Any, item: &item, recreateComposites: recreateComposites)
        } else {
          return nil
        }
      }
    #endif

    return item
  }

  func prepare(component: Component, kind: String, view: Any, item: inout Item, recreateComposites: Bool) {
    if let view = view as? Wrappable, kind.contains(CompositeComponent.identifier) {
      prepare(component: component, wrappable: view, item: &item, recreateComposites: recreateComposites)
    } else if let view = view as? ItemConfigurable {
      view.configure(with: item)
      item.size.height = view.computeSize(for: item, containerSize: component.view.frame.size).height
      setFallbackViewSize(component: component, item: &item, with: view)
    }
  }

  #if !os(OSX)
  /// Prepare view frame for item
  ///
  /// - parameter view: The view that is going to be prepared.
  func prepare(component: Component, item: Item, view: View) {
    // Set initial size for view
    component.view.frame.size.width = view.frame.size.width

    if let itemConfigurable = view as? ItemConfigurable, view.frame.size.height == 0.0 {
      view.frame.size.height = itemConfigurable.computeSize(for: item, containerSize: component.view.frame.size).height
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
  func prepare(component: Component, wrappable: Wrappable, item: inout Item, recreateComposites: Bool) {
    var height: CGFloat = 0.0

    if recreateComposites {
      component.compositeComponents.filter({ $0.itemIndex == item.index }).forEach {
        $0.component.view.removeFromSuperview()

        if let index = component.compositeComponents.index(of: $0) {
          component.compositeComponents.remove(at: index)
        }
      }
    }

    let components: [Component] = Parser.parse(item)
    var size = component.view.frame.size

    if let spanWidth = calculateSpanWidth(for: component) {
      size.width = spanWidth
    }

    size.width = round(size.width)

    components.forEach { childComponent in
      let compositeSpot = CompositeComponent(component: childComponent,
                                             itemIndex: item.index)
      compositeSpot.component.parentComponent = component
      compositeSpot.component.setup(with: size)

      #if !os(OSX)
        /// Disable scrolling for listable objects
        compositeSpot.component.view.isScrollEnabled = !(compositeSpot.component.view is TableView)
      #endif

      height += compositeSpot.component.computedHeight

      if recreateComposites {
        component.compositeComponents.append(compositeSpot)
      }
    }

    item.size.height = height
  }

  /// Set fallback size to view
  ///
  /// - Parameters:
  ///   - item: The item struct that is being configured.
  ///   - view: The view used for fallback size for the item.
  private func setFallbackViewSize(component: Component, item: inout Item, with view: ItemConfigurable) {
    let hasExplicitHeight: Bool = item.size.height == 0.0

    if hasExplicitHeight {
      item.size.height = view.computeSize(for: item, containerSize: component.view.frame.size).height
    }

    if item.size.width == 0.0 {
      item.size.width  = view.computeSize(for: item, containerSize: component.view.frame.size).width
    }

    if let superview = component.view.superview, item.size.width == 0.0 {
      item.size.width = superview.frame.width
    }

    if let view = view as? View, item.size.width == 0.0 || item.size.width > view.bounds.width {
      item.size.width = view.bounds.width
    }
  }

  /// Resolve size property for an item at index path inside component.
  /// This method is used to ensure that user interface never receive negative
  /// size values as that can lead to the user interface implementation throwing
  /// an exception.
  ///
  /// - Parameters:
  ///   - indexPath: The index path of the item.
  ///   - component: The component that item resides in.
  /// - Returns: The size of the item, unless the size is negative, then it will return zero.
  public func sizeForItem(at indexPath: IndexPath, in component: Component) -> CGSize {
    var size = component.item(at: indexPath)?.size ?? .zero
    size.width = max(size.width, 0)
    size.height = max(size.height, 0)

    #if os(macOS)
      // Make sure that the item width never exceeds the frame view width.
      // If it does exceed the maximum width, the layout span will be used to reduce the size to make sure
      // that all items fit on the same row.
      if component.model.layout.span > 0 {
        let inset = CGFloat(component.model.layout.inset.left + component.model.layout.inset.right)
        let maxWidth = size.width * CGFloat(component.model.layout.span) + inset

        if maxWidth >= component.view.frame.size.width {
          size.width = component.view.frame.size.width / CGFloat(component.model.layout.span)
          size.width -= CGFloat(component.model.layout.inset.left)
          size.width -= CGFloat(component.model.layout.inset.right)
          size.width = round(size.width) - 1
        }
      }
    #endif
    return size
  }
}
