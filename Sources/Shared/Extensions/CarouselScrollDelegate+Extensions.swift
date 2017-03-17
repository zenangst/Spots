public extension CarouselScrollDelegate {

  /// Invoked when ever a user scrolls a CarouselComponent.
  ///
  /// - parameter component: The component that was scrolled.
  func componentCarouselDidScroll(_ component: Component) {}

  /// - parameter component: The component that was scrolled.
  /// - parameter item: The last view model in the component
  /// - parameter animated: Indicates if the scrolling animated or not.
  func componentCarouselDidEndScrolling(_ component: Component, item: Item, animated: Bool) {}
}
