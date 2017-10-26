import Foundation

/// A content inset struct used for configuring layout on components.
public struct Inset: Codable, Equatable {
  /// A string enum use for constructing a JSON dictionary representation.
  enum Key: String, CodingKey {
    case top
    case left
    case bottom
    case right
  }

  /// Top content inset.
  var top: Double = 0.0
  /// Left content inset.
  var left: Double = 0.0
  /// Bottom content inset.
  var bottom: Double = 0.0
  /// Right content inset.
  var right: Double = 0.0

  /// A convenience init for initializing a content inset.
  ///
  /// - Parameters:
  ///   - top: Top content inset.
  ///   - left: Left content inset.
  ///   - bottom: Bottom content inset.
  ///   - right: Right content inset.
  public init(top: Double = 0.0, left: Double = 0.0, bottom: Double = 0.0, right: Double = 0.0) {
    self.top = top
    self.left = left
    self.bottom = bottom
    self.right = right
  }

  /// A convenience initializer with default values.
  public init() {}

  /// A convenience init for initializing a content inset with the same values for all properties.
  ///
  /// - Parameter padding: The amount of inset that should be set for all direction.
  public init(padding: Double = 0.0) {
    self.top = padding
    self.left = padding
    self.bottom = padding
    self.right = padding
  }

  /// A convenience init for initializing a content inset using block syntax.
  ///
  /// - Parameter block: A mutating closure.
  public init(_ block: (inout Inset) -> Void) {
    self.init()
    block(&self)
  }

  /// Initialize with a decoder.
  ///
  /// - Parameter decoder: A decoder that can decode values into in-memory representations.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Key.self)
    self.top = try container.decodeIfPresent(Double.self, forKey: .top) ?? 0.0
    self.left = try container.decodeIfPresent(Double.self, forKey: .left) ?? 0.0
    self.bottom = try container.decodeIfPresent(Double.self, forKey: .bottom) ?? 0.0
    self.right = try container.decodeIfPresent(Double.self, forKey: .right) ?? 0.0
  }

  /// Check if to content insets are equal.
  ///
  /// - parameter lhs: Left hand content inset.
  /// - parameter rhs: Right hand content inset.
  ///
  /// - returns: A boolean value, true if both content insets are equal.
  public static func == (lhs: Inset, rhs: Inset) -> Bool {
    return lhs.top == rhs.top
      && lhs.left == rhs.left
      && lhs.bottom == rhs.bottom
      && lhs.right == rhs.right
  }
}
