public extension CarouselScrollDelegate {

  /// Invoked when ever a user scrolls a CarouselComponent.
  ///
  /// - parameter component: The component that was scrolled.
  func componentCarouselDidScroll(_ component: CoreComponent) {}

  /// - parameter component: Object that comforms to the CoreComponent protocol
  /// - parameter item: The last view model in the component
  /// - parameter animated: Indicates if the scrolling animated or not.
  func componentCarouselDidEndScrolling(_ component: CoreComponent, item: Item, animated: Bool) {}
}
