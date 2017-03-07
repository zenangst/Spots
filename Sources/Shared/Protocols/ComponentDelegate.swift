/// A generic delegate for Spots
public protocol ComponentDelegate: class {

  /// A delegate method that is triggered when ever a cell is tapped by the user.
  ///
  /// - parameter component: An object that conforms to the spotable protocol.
  /// - parameter itemSelected: The data for the view that is going to be displayed.
  func component(_ component: CoreComponent, itemSelected item: Item)

  /// A delegate method that is triggered when components is changed.
  ///
  /// - parameter components: New collection of CoreComponent objects
  func componentsDidChange(_ components: [CoreComponent])

  /// A delegate method that is triggered when ever a view is going to be displayed.
  ///
  /// - parameter component: An object that conforms to the spotable protocol.
  /// - parameter view: The UI element that will be displayed.
  /// - parameter item: The data for the view that is going to be displayed.
  func component(_ component: CoreComponent, willDisplay view: ComponentView, item: Item)

  /// A delegate method that is triggered when ever a view will no longer be displayed.
  ///
  /// - parameter component: An object that conforms to the spotable protocol.
  /// - parameter view: The UI element that did end display.
  /// - parameter item: The data for the view that is going to be displayed.
  func component(_ component: CoreComponent, didEndDisplaying view: ComponentView, item: Item)
}
