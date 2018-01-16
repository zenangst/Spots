import Foundation

// MARK: - ComponentDelegate extension
public extension ComponentDelegate {
  /// Triggered when ever a user taps on an item
  ///
  /// - parameter component: The component that the item belongs to.
  /// - parameter item: The item struct that the user tapped on.
  func component(_ component: Component, itemSelected item: Item) {}

  /// Invoked when ever the collection of components changes on the Controller.
  ///
  /// - parameter components: The collection of new components.
  func componentsDidChange(_ components: [Component]) {}

  #if os(tvOS)
  /// A collection of strings that represent the contents of your component.
  ///
  /// - Parameter component: The component that owns the collection of strings.
  /// - Returns: A collection of strings used for accelerated scrolling indexing.
  func componentIndexTitles(_ component: Component) -> [String]? {
    return nil
  }

  /// The index path of the current indexed string.
  ///
  /// - Parameters:
  ///   - component: The component that owns the items.
  ///   - item: The item that is located at the index.
  ///   - index: The index of the current item.
  ///   - title: The title that the item is matched against.
  /// - Returns: The index path used for focusing when using accelerated scrolling.
  func componentIndexPath(_ component: Component, item: Item, at index: Int, for title: String) -> IndexPath {
    return IndexPath(item: index, section: 0)
  }
  #endif

  /// A delegate method that is triggered when ever a view is going to be displayed.
  ///
  /// - parameter component: The component that will display the view.
  /// - parameter view: The UI element that will be displayed.
  /// - parameter item: The data for the view that is going to be displayed.
  func component(_ component: Component, willDisplay view: ComponentView, item: Item) {}

  /// A delegate method that is triggered when ever a view will no longer be displayed.
  ///
  /// - parameter component: The component that will stop displaying the view.
  /// - parameter view: The UI element that did end display.
  /// - parameter item: The data for the view that is going to be displayed.
  func component(_ component: Component, didEndDisplaying view: ComponentView, item: Item) {}

  #if os(macOS)
  /// Get notified when the selection changes in a component.
  ///
  /// - Parameters:
  ///   - component: The component that changed selection.
  ///   - selectedIndexes: The selected indexes.
  func component(_ component: Component, didChangeSelection selectedIndexes: [Int]) {}
  #endif

  func component(_ component: Component, didConfigureHeader view: ComponentView, item: Item) {}
  func component(_ component: Component, didConfigureFooter view: ComponentView, item: Item) {}
}
