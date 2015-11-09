import Tailor
import Sugar

public struct Component: Mappable {
  public var title = ""
  public var kind = ""
  public var span = 1
  public var items = [ListItem]()
  public var meta = [String : String]()

  public init(_ map: JSONDictionary) {
    title <- map.property("title")
    kind  <- map.property("type")
    span  <- map.property("span")
    items <- map.objects("items")
    meta  <- map.property("meta")
  }

  public init(title: String = "", kind: String = "", span: Int = 1, items: [ListItem] = [ListItem](), meta: [String : String] = [:]) {
    self.title = title
    self.kind = kind
    self.span = span
    self.items = items
    self.meta = meta
  }
}
