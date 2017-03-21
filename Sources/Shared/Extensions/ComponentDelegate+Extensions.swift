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
}
