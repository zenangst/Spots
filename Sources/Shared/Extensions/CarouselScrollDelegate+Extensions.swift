public extension CarouselScrollDelegate {

  /// Invoked when ever a user scrolls a CarouselSpot.
  ///
  /// - parameter spot: The spotable object that was scrolled.
  func spotableCarouselDidScroll(_ spot: Spotable) {}

  /// - parameter spot: Object that comforms to the Spotable protocol
  /// - parameter item: The last view model in the component
  /// - parameter animated: Indicates if the scrolling animated or not.
  func spotableCarouselDidEndScrolling(_ spot: Spotable, item: Item, animated: Bool) {}
}
