public extension CarouselScrollDelegate {

  /// Invoked when ever a user scrolls a CarouselComponent.
  ///
  /// - parameter spot: The spotable object that was scrolled.
  func spotableCarouselDidScroll(_ spot: CoreComponent) {}

  /// - parameter spot: Object that comforms to the CoreComponent protocol
  /// - parameter item: The last view model in the component
  /// - parameter animated: Indicates if the scrolling animated or not.
  func spotableCarouselDidEndScrolling(_ spot: CoreComponent, item: Item, animated: Bool) {}
}
