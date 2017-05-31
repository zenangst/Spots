# Delegates

### ComponentDelegate

```swift
public protocol ComponentDelegate: class {
  func component(_ component: Component, itemSelected item: Item)
  func componentsDidChange(_ components: [Component])
  func component(_ component: Component, willDisplay view: ComponentView, item: Item)
  func component(_ component: Component, didEndDisplaying view: ComponentView, item: Item)
}
```

`component(_ component: Component, itemSelected item: Item)` is triggered when a user taps on an item inside of a `Component`. It returns both the `component` and the `item` to add context to what UI element was selected.

`componentsDidChange` notifies the delegate when the internal `.components` property changes.

### RefreshDelegate (only supported on iOS)

```swift
public protocol RefreshDelegate: class {
  func componentsDidReload(_ components: [Component], refreshControl: UIRefreshControl, completion: Completion)
}
```

`componentsDidReload` is triggered when a user pulls the `SpotsScrollView` offset above its initial bounds.

### ScrollDelegate

```swift
public protocol ScrollDelegate: class {
  func didReachBeginning(in scrollView: ScrollableView, completion: Completion)
  func didReachEnd(in scrollView: ScrollableView, completion: Completion)
}
```

`didReachBeginning` notifies the delegate when the scrollview has reached the top. This has a default implementation and is rendered optional for anything that conform to `SpotsScrollDelegate`.

`didReachEnd` is triggered when the user scrolls to the end of the `SpotsScrollView`, this can be used to implement infinite scrolling.

### CarouselScrollDelegate

```swift
public protocol CarouselScrollDelegate: class {
  func componentCarouselDidScroll(_ component: Component)
  func componentCarouselDidEndScrolling(_ component: Component, item: Item, animated: Bool)
}
```

`componentCarouselDidEndScrolling` is triggered when a user ends scrolling in a carousel, it returns item that is being displayed and the component to give you the context that you need.
