/**
 A protocol for returning a dictionary representation of self
 */
public protocol DictionaryConvertible {
  var dictionary: [String : Any] { get }
}
