import Foundation

/// Indicates if the UI has vertical or horizontal scrolling.
///
/// - horizontal: UI uses horizontal scrolling.
/// - vertical: UI uses vertical scrolling.
enum ScrollDirection: String, Codable {
  case horizontal, vertical
}

/// Configures what kind of click behavior the component should use.
///
/// - single: Single mouse click.
/// - double: Double mouse click (only supported on components that use table views).
public enum MouseClick: String, Codable {
  case single, double
}

/// A user interaction struct used for mapping behavior to a component.
/// Note: `paginate` is currently only available on iOS.
public struct Interaction: Codable {

  /// A string based enum for keys used when encoding and decoding the struct from and to JSON.
  ///
  /// - paginate: Used for mapping pagination behavior.
  enum Key: String, CodingKey {
    case paginate
    case scrollDirection = "scroll-direction"
    case mouseClick
  }

  /// Delcares what kind of interaction should be used for pagination. See `Paginate` struct for more information.
  var paginate: Paginate = .disabled
  /// Indicates which scrolling direction will be used, default to false.
  var scrollDirection: ScrollDirection = .vertical
  /// Indicates what kind click interaction the element should use.
  var mouseClick: MouseClick = .single

  /// A convenience initializer with default values.
  public init() {
    self.paginate = .disabled
  }

  /// Default initializer for creating a Interaction struct.
  ///
  /// - Parameter paginate: Declares which pagination behavior that should be used, `.disabled` is default.
  public init(paginate: Paginate = .disabled, mouseClick: MouseClick = .single) {
    self.paginate = paginate
    self.mouseClick = mouseClick
  }

  // MARK: - Codable

  /// Initialize with a decoder.
  ///
  /// - Parameter decoder: A decoder that can decode values into in-memory representations.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Key.self)
    self.paginate = try container.decodeIfPresent(Paginate.self, forKey: .paginate) ?? .disabled
    self.scrollDirection = try container.decodeIfPresent(ScrollDirection.self,
                                                         forKey: .scrollDirection) ?? .vertical
    self.mouseClick = try container.decodeIfPresent(MouseClick.self, forKey: .mouseClick) ?? .single
  }

  /// Compare Interaction structs.
  ///
  /// - Parameters:
  ///   - lhs: Left hand side Interaction
  ///   - rhs: Right hand side Interaction
  /// - Returns: A boolean value that is true if all properties are equal on the struct.
  public static func == (lhs: Interaction, rhs: Interaction) -> Bool {
    return lhs.paginate == rhs.paginate &&
      lhs.mouseClick == rhs.mouseClick
  }

  /// Compare Interaction structs.
  ///
  /// - Parameters:
  ///   - lhs: Left hand side Interaction
  ///   - rhs: Right hand side Interaction
  /// - Returns: A boolean value that is true if all properties are not equal on the struct.
  public static func != (lhs: Interaction, rhs: Interaction) -> Bool {
    return !(lhs == rhs)
  }
}
