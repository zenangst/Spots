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
