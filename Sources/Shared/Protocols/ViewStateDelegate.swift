public protocol ViewStateDelegate: class {

  /// Invoked when ever a view state is changed.
  ///
  /// - parameter viewState: The current view state.
  func viewStateDidChange(_ viewState: ViewState)
}
