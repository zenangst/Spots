/// An enum for identifing the ComponentModel kind
public enum ComponentKind: String, Equatable {
  /// The identifier for CarouselComponent
  case carousel
  /// The identifier for GridComponent
  case grid
  /// The identifier for ListComponent
  case list

  /// The lowercase raw value of the case
  public var string: String {
    return rawValue.lowercased()
  }

  public static func == (lhs: ComponentKind, rhs: String) -> Bool {
    return lhs.string == rhs
  }
}
