extension CoreComponent {

  func didScrollHorizontally(handler: (ComponentHorizontallyScrollable) -> Void) {
    guard let component = self as? ComponentHorizontallyScrollable,
      model.interaction.scrollDirection == .horizontal else {
        return
    }

    handler(component)
  }
}
