public enum ViewState {
  case normal
  case highlighted
  case selected

  #if os(macOS)
  case hover
  #endif
}
