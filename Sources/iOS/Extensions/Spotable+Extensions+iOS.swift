extension Spotable {
  func didScrollHorizontally(handler: (SpotHorizontallyScrollable) -> Void) {
    guard let spot = self as? SpotHorizontallyScrollable,
      component.interaction.scrollDirection == .horizontal else {
        return
    }

    handler(spot)
  }
}
