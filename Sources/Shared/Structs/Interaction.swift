import Foundation
import Tailor

/// Indicates if the UI has vertical or horizontal scrolling.
///
/// - horizontal: UI uses horizontal scrolling.
/// - vertical: UI uses vertical scrolling.
enum ScrollDirection: String {
  case horizontal, vertical
}

/// Configures what kind of click behavior the component should use.
///
/// - single: Single mouse click.
/// - double: Double mouse click (only supported on components that use table views).
public enum MouseClick: String {
  case single, double
}

/// A user interaction struct used for mapping behavior to a component.
/// Note: `paginate` is currently only available on iOS.
public struct Interaction: Mappable {

  /// A string based enum for keys used when encoding and decoding the struct from and to JSON.
  ///
  /// - paginate: Used for mapping pagination behavior.
  enum Key: String {
    case paginate, mouseClick
  }

  /// Delcares what kind of interaction should be used for pagination. See `Paginate` struct for more information.
  var paginate: Paginate = .disabled
  /// Indicates which scrolling direction will be used, default to false.
  var scrollDirection: ScrollDirection = .vertical
  /// Indicates what kind click interaction the element should use.
  var mouseClick: MouseClick = .single

  /// The root key used when parsing JSON into a Interaction struct.
  static let rootKey: String = String(describing: Interaction.self).lowercased()

  /// A dictionary representation of the struct.
  public var dictionary: [String : Any] {
    return [
      Key.mouseClick.rawValue: mouseClick.rawValue,
      Key.paginate.rawValue: paginate.rawValue
    ]
  }

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

  /// Initialize with a JSON payload.
  ///
  /// - Parameter map: A JSON dictionary.
  public init(_ map: [String : Any] = [:]) {
    configure(withJSON: map)
  }

  /// Configure struct with a JSON dictionary.
  ///
  /// - Parameter map: A JSON dictionary.
  public mutating func configure(withJSON map: [String : Any]) {
    if let paginate: String = map.property(Key.paginate.rawValue) {
      self.paginate <- Paginate(rawValue: paginate)
    }

    if let mouseClick: String = map.property(Key.mouseClick.rawValue) {
      self.mouseClick <- MouseClick(rawValue: mouseClick)
    }
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
