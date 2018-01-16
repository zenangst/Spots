import Foundation

/// A generic delegate for Spots
public protocol ComponentDelegate: class {

  /// A delegate method that is triggered when ever a cell is tapped by the user.
  ///
  /// - parameter component: The component that was selected.
  /// - parameter itemSelected: The data for the view that is going to be displayed.
  func component(_ component: Component, itemSelected item: Item)

  /// A delegate method that is triggered when components is changed.
  ///
  /// - parameter components: New collection of components.
  func componentsDidChange(_ components: [Component])

  #if os(tvOS)
  func componentIndexTitles(_ component: Component) -> [String]?

  func componentIndexPath(_ component: Component, item: Item, at index: Int, for title: String) -> IndexPath
  #endif

  /// This delegate method will be called when the header view is configured in the component.
  ///
  /// - Parameters:
  ///   - component: The component that the header view belongs to.
  ///   - view: The header view that has been configured.
  ///   - item: The item of the header model.
  func component(_ component: Component, didConfigureHeader view: ComponentView, item: Item)

  /// This delegate method will be called when the footer vis is configured in the component.
  ///
  /// - Parameters:
  ///   - component: The component that the header view belongs to.
  ///   - view: The header view that has been configured.
  ///   - item: The item of the header model.
  func component(_ component: Component, didConfigureFooter view: ComponentView, item: Item)

  /// A delegate method that is triggered when ever a view is going to be displayed.
  ///
  /// - parameter component: The component that will display the item.
  /// - parameter view: The UI element that will be displayed.
  /// - parameter item: The data for the view that is going to be displayed.
  func component(_ component: Component, willDisplay view: ComponentView, item: Item)

  /// A delegate method that is triggered when ever a view will no longer be displayed.
  ///
  /// - parameter component: The component that will stop displaying the item.
  /// - parameter view: The UI element that did end display.
  /// - parameter item: The data for the view that is going to be displayed.
  func component(_ component: Component, didEndDisplaying view: ComponentView, item: Item)

  #if os(macOS)
  /// Get notified when the selection changes in a component.
  ///
  /// - Parameters:
  ///   - component: The component that changed selection.
  ///   - selectedIndexes: The selected indexes.
  func component(_ component: Component, didChangeSelection selectedIndexes: [Int])
  #endif
}
