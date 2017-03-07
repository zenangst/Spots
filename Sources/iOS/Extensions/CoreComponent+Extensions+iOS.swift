extension CoreComponent {

  func didScrollHorizontally(handler: (SpotHorizontallyScrollable) -> Void) {
    guard let spot = self as? SpotHorizontallyScrollable,
      model.interaction.scrollDirection == .horizontal else {
        return
    }

    handler(spot)
  }
}
