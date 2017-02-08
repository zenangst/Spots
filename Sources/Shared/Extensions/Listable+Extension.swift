extension Listable {

  public func configure(with layout: Layout) {
    layout.configure(spot: self)
  }
}
