extension Component {

  func didScrollHorizontally(handler: (Component) -> Void) {
    guard model.interaction.scrollDirection == .horizontal,
      model.interaction.paginate != .disabled else {
        return
    }

    handler(self)
  }
}
