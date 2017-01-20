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
  func spotsDidChange(spots: [Spotable])

  /// A delegate method that is triggered when ever a view is going to be displayed.
  ///
  /// - parameter item: The data for the view that is going to be displayed.
  /// - parameter spot: An object that conforms to the spotable protocol.
  func spotsWillDisplay(view: SpotView, item: Item, in spot: Spotable)

  /// A delegate method that is triggered when ever a view will no longer be displayed.
  ///
  /// - parameter item: The data for the view that is going to be displayed.
  /// - parameter spot: An object that conforms to the spotable protocol.
  func spotsEndDisplay(view: SpotView, item: Item, in spot: Spotable)
}

// MARK: - SpotsDelegate extension
public extension SpotsDelegate {

  /// Triggered when ever a user taps on an item
  ///
  /// - parameter item: The item struct that the user tapped on.
  /// - parameter spot: The spotable object that the item belongs to.
  func spotable(_ spot: Spotable, itemSelected item: Item) {}

  /// Invoked when ever the collection of spotable objects changes on the Controller.
  ///
  /// - parameter spots: The collection of new Spotable objects.
  func spotsDidChange(_ spots: [Spotable]) {}

  func spotsWillDisplay(view: SpotView, item: Item, in spot: Spotable) {}
  func spotsEndDisplay(view: SpotView, item: Item, in spot: Spotable) {}
}

/// A refresh delegate for handling reloading of a Spot
public protocol RefreshDelegate: class {

  /// A delegate method for when your spot controller was refreshed using pull to refresh
  ///
  /// - parameter refreshControl: A UIRefreshControl
  /// - parameter completion: A completion closure that should be triggered when the update is completed
  #if os(iOS)
  func spotsDidReload(_ refreshControl: UIRefreshControl, completion: Completion)
  #endif
}

public protocol CarouselScrollDelegate: class {

  /// Invoked when ever a user scrolls a CarouselSpot.
  ///
  /// - parameter spot: The spotable object that was scrolled.
  func spotsCarouselDidScroll(in spot: Spotable)

  /// - parameter spot: Object that comforms to the Spotable protocol
  /// - parameter item: The last view model in the component
  func spotsCarouselDidEndScrolling(in spot: Spotable, item: Item)

  func spotsCarouselDidEndScrollingAnimated(in spot: Spotable)
}

public extension CarouselScrollDelegate {

  func spotsCarouselDidScroll(in spot: Spotable) {}
  func spotsCarouselDidEndScrolling(in spot: Spotable, item: Item) {}
  func spotsCarouselDidEndScrollingAnimated(in spot: Spotable) {}
}
