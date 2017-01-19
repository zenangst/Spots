import Tailor
import Brick

/// A section inset struct used for configuring layout on Spotable objects.
public struct SectionInset: Mappable, Equatable {

  /// The root key for the JSON dictionary.
  static let rootKey: String = "section-inset"

  /// A string enum use for constructing a JSON dictionary representation.
  enum Key: String {
    case top, left, bottom, right
  }

  /// Top section inset.
  var top: Double = 0.0
  /// Left section inset.
  var left: Double = 0.0
  /// Bottom section inset.
  var bottom: Double = 0.0
  /// Right section inset.
  var right: Double = 0.0

  /// A dictionary representation of the struct.
  public var dictionary: [String : Double] {
    return [
      Key.top.rawValue: self.top,
      Key.left.rawValue: self.left,
      Key.bottom.rawValue: self.bottom,
      Key.right.rawValue: self.right
    ]
  }

  /// A convenience init for initializing a section inset.
  ///
  /// - Parameters:
  ///   - top: Top section inset.
  ///   - left: Left section inset.
  ///   - bottom: Bottom section inset.
  ///   - right: Right section inset.
  public init(top: Double = 0.0, left: Double = 0.0, bottom: Double = 0.0, right: Double = 0.0) {
    self.top = top
    self.left = left
    self.bottom = bottom
    self.right = right
  }

  /// A convenience init for initializing a section inset using block syntax.
  ///
  /// - Parameter block: A mutating closure.
  public init(_ block: (inout SectionInset) -> Void) {
    self.init([:])
    block(&self)
  }

  /// A convenience init for initializing a section inset using a JSON dictionary.
  ///
  /// - Parameter map: A JSON dictionary that will be mapped into the section insets.
  public init(_ map: [String : Any]) {
    self.top    <- map.property(Key.top.rawValue)
    self.left   <- map.property(Key.left.rawValue)
    self.bottom <- map.property(Key.bottom.rawValue)
    self.right  <- map.property(Key.right.rawValue)
  }

  /// Configure struct with a JSON dictionary.
  ///
  /// - Parameter JSON: A JSON dictionary that will be used to configure the section insets.
  public mutating func configure(withJSON JSON: [String : Any]) {
    self.top    <- JSON.property(Key.top.rawValue)
    self.left   <- JSON.property(Key.left.rawValue)
    self.bottom <- JSON.property(Key.bottom.rawValue)
    self.right  <- JSON.property(Key.right.rawValue)
  }

  /// Check if to section insets are equal.
  ///
  /// - parameter lhs: Left hand section inset.
  /// - parameter rhs: Right hand section inset.
  ///
  /// - returns: A boolean value, true if both section insets are equal.
  public static func == (lhs: SectionInset, rhs: SectionInset) -> Bool {
    return lhs.top == rhs.top &&
      lhs.left == rhs.left &&
      lhs.bottom == rhs.bottom &&
      lhs.right == rhs.right
  }
}
