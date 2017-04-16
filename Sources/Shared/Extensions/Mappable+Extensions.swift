import Tailor

extension Mappable {

  /**
   - returns: A key-value dictionary.
   */
  var metaProperties: [String : Any] {
    var properties = [String: Any]()

    for tuple in Mirror(reflecting: self).children {
      guard let key = tuple.label else { continue }

      if let value = Mirror(reflecting: tuple.value).descendant("Some") {
        properties[key] = value
      } else {
        properties[key] = tuple.value
      }
    }

    return properties
  }
}
