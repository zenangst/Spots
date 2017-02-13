import Foundation
import Tailor

/// A user interaction struct used for mapping behavior to a Spotable object.
/// Note: `paginate` is currently only available on iOS.
public struct Interaction: Mappable {

  /// A string based enum for keys used when encoding and decoding the struct from and to JSON.
  ///
  /// - paginate: Used for mapping pagination behavior.
  enum Key: String {
    case paginate
  }

  /// Delcares what kind of interaction should be used for pagination. See `Paginate` struct for more information.
  var paginate: Paginate = .disabled
  /// Indicates which scrolling direction will be used, default to false.
  var scrollsHorizontally: Bool = false

  /// The root key used when parsing JSON into a Interaction struct.
  static let rootKey: String = String(describing: Interaction.self).lowercased()

  /// A dictionary representation of the struct.
  public var dictionary: [String : Any] {
    return [
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
  public init(paginate: Paginate = .disabled) {
    self.paginate = paginate
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
    if Component.legacyMapping {
      if let _: Bool = map.property(Key.paginate.rawValue) {
        self.paginate = .page
      }
    } else if let paginate: String = map.property(Key.paginate.rawValue) {
      self.paginate <- Paginate(rawValue: paginate)
    }
  }

  /// Compare Interaction structs.
  ///
  /// - Parameters:
  ///   - lhs: Left hand side Interaction
  ///   - rhs: Right hand side Interaction
  /// - Returns: A boolean value that is true if all properties are equal on the struct.
  public static func == (lhs: Interaction, rhs: Interaction) -> Bool {
    return lhs.paginate == rhs.paginate
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
