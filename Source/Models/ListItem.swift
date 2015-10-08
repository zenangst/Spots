import Tailor
import Sugar

public protocol Listable { }

public struct ListItem: Mappable, Listable {
  public var title = ""
  public var subtitle = ""
  public var image = ""
  public var kind = ""
  public var uri: String?

  public init(_ map: JSONDictionary) {
    title    <- map.property("title")
    subtitle <- map.property("subtitle")
    image    <- map.property("image")
    kind     <- map.property("type")
    uri      <- map.property("uri")
  }
}
