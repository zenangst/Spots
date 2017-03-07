extension CoreComponent {

  func didScrollHorizontally(handler: (ComponentHorizontallyScrollable) -> Void) {
    guard let spot = self as? ComponentHorizontallyScrollable,
      model.interaction.scrollDirection == .horizontal else {
        return
    }

    handler(spot)
  }
}
