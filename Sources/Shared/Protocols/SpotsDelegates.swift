import Brick

#if os(iOS)
  import UIKit
#endif

/// A protocol for composite delegates
public protocol CompositeDelegate: class {
  /// A collection of composite spotable objects, indexed by Spotable object index and Item index.
  var compositeSpots: [Int : [Int : [Spotable]]] { get set }
}

// MARK: - CompositeDelegate extension
extension CompositeDelegate {

  /// Resolve composite container using spot index and item index.
  ///
  /// - parameter spotIndex: The index of the Spotable object.
  /// - parameter itemIndex: The index of the Item that is being displayed on screen.
  ///
  /// - returns: A collection of Spotable objects.
  func resolve(_ spotIndex: Int, itemIndex: Int) -> [Spotable]? {
    guard let compositeContainer = compositeSpots[spotIndex],
      let result = compositeContainer[itemIndex] else {
        return nil
    }

    return result
  }
}

/// A generic delegate for Spots
public protocol SpotsDelegate: class {

  /// A delegate method that is triggered when spots is changed
  ///
  /// - parameter spots: New collection of Spotable objects
  func didChange(spots: [Spotable])

  /// A delegate method that is triggered when ever a cell is tapped by the user
  ///
  /// - parameter item: The data for the view that is going to be displayed.
  /// - parameter spot: An object that conforms to the spotable protocol.
  func didSelect(item: Item, in spot: Spotable)

  /// A delegate method that is triggered when ever a view is going to be displayed
  ///
  /// - parameter item: The data for the view that is going to be displayed.
  /// - parameter spot: An object that conforms to the spotable protocol.
  func willDisplay(item: Item, in spot: Spotable)

  /// A delegate method that is triggered when ever a view will no longer be displayed.
  ///
  /// - parameter item: The data for the view that is going to be displayed.
  /// - parameter spot: An object that conforms to the spotable protocol.
  func endDisplay(item: Item, in spot: Spotable)
}

// MARK: - SpotsDelegate extension
public extension SpotsDelegate {

  /// Triggered when ever a user taps on an item
  ///
  /// - parameter item: The item struct that the user tapped on.
  /// - parameter spot: The spotable object that the item belongs to.
  func didSelect(item: Item, in spot: Spotable) {}

  /// Invoked when ever the collection of spotable objects changes on the Controller.
  ///
  /// - parameter spots: The collection of new Spotable objects.
  func didChange(spots: [Spotable]) {}

  func willDisplay(item: Item, in spot: Spotable) {}
  func endDisplay(item: Item, in spot: Spotable) {}
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
  func didScroll(in spot: Spotable)

  /// - parameter spot: Object that comforms to the Spotable protocol
  /// - parameter item: The last view model in the component
  func didEndScrolling(in spot: Spotable, item: Item)

  func didEndScrollingAnimated(in spot: Spotable)
}

public extension CarouselScrollDelegate {

  func didScroll(in spot: Spotable) {}
  func didEndScrolling(in spot: Spotable, item: Item) {}
  func didEndScrollingAnimated(in spot: Spotable) {}
}
