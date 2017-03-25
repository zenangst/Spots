protocol Cell {
  var isHighlighted: Bool { get }
  var isSelected: Bool { get }
}

extension Cell {

  var viewState: ViewState {
    if isHighlighted {
      return .highlighted
    } else if isSelected {
      return .selected
    } else {
      return .normal
    }
  }
}
