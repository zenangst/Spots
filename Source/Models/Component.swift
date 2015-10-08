import Tailor
import Sugar

public struct Component: Mappable {
  public var title = ""
  public var kind = ""
  public var span = 1
  public var items = [ListItem]()

  public init(_ map: JSONDictionary) {
    title <- map.property("title")
    kind  <- map.property("type")
    span  <- map.property("span")
    items <- map.objects("items")
  }
}
