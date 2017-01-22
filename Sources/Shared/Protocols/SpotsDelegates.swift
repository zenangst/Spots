import Brick

#if os(iOS)
  import UIKit
#endif

public protocol SpotsFocusDelegate: class {
  var focusedSpot: Spotable? { get set }
  var focusedItemIndex: Int? { get set }
}

/// A generic delegate for Spots
public protocol SpotsDelegate: class {

  /// A delegate method that is triggered when ever a cell is tapped by the user.
  ///
  /// - parameter spot: An object that conforms to the spotable protocol.
  /// - parameter itemSelected: The data for the view that is going to be displayed.
  func spotable(_ spot: Spotable, itemSelected item: Item)

  /// A delegate method that is triggered when spots is changed.
  ///
  /// - parameter spots: New collection of Spotable objects
  func spotablesDidChange(_ spots: [Spotable])

  /// A delegate method that is triggered when ever a view is going to be displayed.
  ///
  /// - parameter spot: An object that conforms to the spotable protocol.
  /// - parameter view: The UI element that will be displayed.
  /// - parameter item: The data for the view that is going to be displayed.
  func spotable(_ spot: Spotable, willDisplay view: SpotView, item: Item)

  /// A delegate method that is triggered when ever a view will no longer be displayed.
  ///
  /// - parameter spot: An object that conforms to the spotable protocol.
  /// - parameter view: The UI element that did end display.
  /// - parameter item: The data for the view that is going to be displayed.
  func spotable(_ spot: Spotable, didEndDisplaying view: SpotView, item: Item)
}

// MARK: - SpotsDelegate extension
public extension SpotsDelegate {

  /// Triggered when ever a user taps on an item
  ///
  /// - parameter spot: The spotable object that the item belongs to.
  /// - parameter item: The item struct that the user tapped on.
  func spotable(_ spot: Spotable, itemSelected item: Item) {}

  /// Invoked when ever the collection of spotable objects changes on the Controller.
  ///
  /// - parameter spots: The collection of new Spotable objects.
  func spotablesDidChange(_ spots: [Spotable]) {}

  /// A delegate method that is triggered when ever a view is going to be displayed.
  ///
  /// - parameter spot: An object that conforms to the spotable protocol.
  /// - parameter view: The UI element that will be displayed.
  /// - parameter item: The data for the view that is going to be displayed.
  func spotable(_ spot: Spotable, willDisplay view: SpotView, item: Item) {}

  /// A delegate method that is triggered when ever a view will no longer be displayed.
  ///
  /// - parameter spot: An object that conforms to the spotable protocol.
  /// - parameter view: The UI element that did end display.
  /// - parameter item: The data for the view that is going to be displayed.
  func spotable(_ spot: Spotable, didEndDisplaying view: SpotView, item: Item) {}
}

/// A refresh delegate for handling reloading of a Spot
public protocol RefreshDelegate: class {

  /// A delegate method for when your spot controller was refreshed using pull to refresh
  ///
  /// - parameter spots: A collection of Spotable objects
  /// - parameter refreshControl: A UIRefreshControl
  /// - parameter completion: A completion closure that should be triggered when the update is completed
  #if os(iOS)
  func spotablesDidReload(_ spots: [Spotable], refreshControl: UIRefreshControl, completion: Completion)
  #endif
}

public protocol CarouselScrollDelegate: class {

  /// Invoked when ever a user scrolls a CarouselSpot.
  ///
  /// - parameter spot: The spotable object that was scrolled.
  func spotableCarouselDidScroll(_ spot: Spotable)

  /// - parameter spot: Object that comforms to the Spotable protocol
  /// - parameter item: The last view model in the component
  func spotableCarouselDidEndScrolling(_ spot: Spotable, item: Item)

  /// - parameter spot: Object that comforms to the Spotable protocol
  func spotableCarouselDidEndScrollingAnimated(_ spot: Spotable)
}

public extension CarouselScrollDelegate {

  /// Invoked when ever a user scrolls a CarouselSpot.
  ///
  /// - parameter spot: The spotable object that was scrolled.
  func spotableCarouselDidScroll(_ spot: Spotable) {}

  /// - parameter spot: Object that comforms to the Spotable protocol
  /// - parameter item: The last view model in the component
  func spotableCarouselDidEndScrolling(_ spot: Spotable, item: Item) {}

  /// - parameter spot: Object that comforms to the Spotable protocol
  func spotableCarouselDidEndScrollingAnimated(_ spot: Spotable) {}
}
