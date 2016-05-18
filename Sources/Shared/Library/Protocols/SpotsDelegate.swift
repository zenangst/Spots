import Brick

/// A generic delegate for Spots
public protocol SpotsDelegate: class {

  /**
   A delegate method that is triggered when spots is changed

   - parameter spots: New collection of Spotable objects
   */
  func spotsDidChange(spots: [Spotable])

  /**
   A delegate method that is triggered when ever a cell is tapped by the user

   - Parameter spot: An object that conforms to the spotable protocol
   - Parameter item: The view model that was tapped
   */
  func spotDidSelectItem(spot: Spotable, item: ViewModel)
}

public extension SpotsDelegate {

  func spotDidSelectItem(spot: Spotable, item: ViewModel) {}
  func spotsDidChange(spots: [Spotable]) {}
}