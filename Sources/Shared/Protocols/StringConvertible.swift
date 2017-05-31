/**
 A protocol for returning a string representation of self
 */
public protocol StringConvertible {
  var string: String { get }
}

/**
  A protocol extension on String to make it conform to StringConvertible
 */
extension String: StringConvertible {

  /**
   The required implementation for String to make it conform to StringConvertible

   - returns: self as string
  */
  public var string: String {
    return self
  }
}

/**
 A protocol extension on RawRepresentable to make it conform to StringConvertible
 */
extension StringConvertible where Self: RawRepresentable, Self.RawValue == String {

  /**
   The required implementation for RawRepresentable to make it conform to StringConvertible

   - returns: rawValue as string
   */
  public var string: String {
    return rawValue
  }
}
