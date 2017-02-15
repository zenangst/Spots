public extension Wrappable {

  func configure(with view: View) {
    if let previousView = self.wrappedView {
      previousView.removeFromSuperview()
    }

    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.frame = bounds
    self.wrappedView = view
    configureWrappedView()

    contentView.addSubview(view)
  }

  func configureWrappedView() {}
}
