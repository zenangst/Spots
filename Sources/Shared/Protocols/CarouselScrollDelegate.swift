public protocol CarouselScrollDelegate: class {

  /// Invoked when ever a user scrolls a CarouselSpot.
  ///
  /// - parameter spot: The spotable object that was scrolled.
  func spotableCarouselDidScroll(_ spot: Spotable)

  /// - parameter spot: Object that comforms to the Spotable protocol
  /// - parameter item: The last view model in the component
  func spotableCarouselDidEndScrolling(_ spot: Spotable, item: Item, animated: Bool)
}
