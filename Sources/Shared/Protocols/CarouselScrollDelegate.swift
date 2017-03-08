public protocol CarouselScrollDelegate: class {

  /// Invoked when ever a user scrolls a CarouselComponent.
  ///
  /// - parameter component: The component that was scrolled.
  func componentCarouselDidScroll(_ component: CoreComponent)

  /// - parameter component: Object that comforms to the CoreComponent protocol
  /// - parameter item: The last view model in the component
  func componentCarouselDidEndScrolling(_ component: CoreComponent, item: Item, animated: Bool)
}
