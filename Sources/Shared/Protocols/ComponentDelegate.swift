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
}
