extension UserInterface {

  func resolveVisibleView(_ view: View) -> View {
    guard let wrappedView = (view as? Wrappable)?.wrappedView else {
      return view
    }

    return wrappedView
  }
}
