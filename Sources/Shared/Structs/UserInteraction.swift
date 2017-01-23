import Foundation
import Tailor

/// A user interaction struct used for mapping behavior to a Spotable object.
/// Note: `paginate` is currently only available on iOS.
public struct UserInteraction: Mappable {

  /// A string based enum for keys used when encoding and decoding the struct from and to JSON.
  ///
  /// - paginate: Used for mapping pagination behavior.
  enum Key: String {
    case paginate = "paginate"
  }

  /// Delcares what kind of interaction should be used for pagination. See `Paginate` struct for more information.
  var paginate: Paginate = .disabled

  /// The root key used when parsing JSON into a UserInteraction struct.
  static let rootKey: String = "user-interaction"

  /// A dictionary representation of the struct.
  public var dictionary: [String : Any] {
    return [
      Key.paginate.rawValue: paginate.rawValue
    ]
  }

  /// Initialize with a JSON payload.
  ///
  /// - Parameter map: A JSON dictionary.
  public init(_ map: [String : Any] = [:]) {
    configure(withJSON: map)
  }

  /// A convenience initializer with default values.
  public init() {
    self.paginate = .disabled
  }

  /// Default initializer for creating a UserInteraction struct.
  ///
  /// - Parameter paginate: Declares which pagination behavior that should be used, `.disabled` is default.
  public init(paginate: Paginate = .disabled) {
    self.paginate = paginate
  }

  /// Configure struct with a JSON dictionary.
  ///
  /// - Parameter map: A JSON dictionary.
  public mutating func configure(withJSON map: [String : Any]) {
    if Component.legacyMapping {
      if let _: Bool = map.property(Key.paginate.rawValue) {
        self.paginate = .byPage
      }
    } else if let paginate: String = map.property(Key.paginate.rawValue) {
      self.paginate <- Paginate(rawValue: paginate)
    }
  }

  /// Compare UserInteraction structs.
  ///
  /// - Parameters:
  ///   - lhs: Left hand side UserInteraction
  ///   - rhs: Right hand side UserInteraction
  /// - Returns: A boolean value that is true if all properties are equal on the struct.
  public static func == (lhs: UserInteraction, rhs: UserInteraction) -> Bool {
    return lhs.paginate == rhs.paginate
  }

  /// Compare UserInteraction structs.
  ///
  /// - Parameters:
  ///   - lhs: Left hand side UserInteraction
  ///   - rhs: Right hand side UserInteraction
  /// - Returns: A boolean value that is true if all properties are not equal on the struct.
  public static func != (lhs: UserInteraction, rhs: UserInteraction) -> Bool {
    return !(lhs == rhs)
  }
}
