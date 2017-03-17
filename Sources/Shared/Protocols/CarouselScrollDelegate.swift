public protocol CarouselScrollDelegate: class {

  /// Invoked when ever a user scrolls a CarouselComponent.
  ///
  /// - parameter component: The component that was scrolled.
  func componentCarouselDidScroll(_ component: Component)

  /// - parameter component: The component that was scrolled.
  /// - parameter item: The last view model in the component
  func componentCarouselDidEndScrolling(_ component: Component, item: Item, animated: Bool)
}
