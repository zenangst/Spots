/// An enum for identifing the ComponentModel kind
public enum ComponentKind: String, Codable, Equatable {
  /// The identifier for CarouselComponent
  case carousel
  /// The identifier for GridComponent
  case grid
  /// The identifier for ListComponent
  case list

  public static func == (lhs: ComponentKind, rhs: String) -> Bool {
    return lhs.rawValue == rhs
  }
}
