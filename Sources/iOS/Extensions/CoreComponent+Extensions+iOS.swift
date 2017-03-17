extension Component {

  func didScrollHorizontally(handler: (Component) -> Void) {
    guard model.interaction.scrollDirection == .horizontal else {
        return
    }

    handler(self)
  }
}
