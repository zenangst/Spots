import Tailor
import Sugar

public struct Component: Mappable {
  public var index = 0
  public var title = ""
  public var kind = ""
  public var span = 1
  public var items = [ListItem]()
  public var size: CGSize?
  public var meta = [String : String]()

  public init(_ map: JSONDictionary) {
    title <- map.property("title")
    kind  <- map.property("type")
    span  <- map.property("span")
    items <- map.objects("items")
    meta  <- map.property("meta")
  }

  public init(title: String = "", kind: String = "", span: Int = 1, items: [ListItem] = [], meta: [String : String] = [:]) {
    self.title = title
    self.kind = kind
    self.span = span
    self.items = items
    self.meta = meta
  }
}

public func ==(lhs: Component, rhs: Component) -> Bool {
  return lhs.title == rhs.title &&
    lhs.kind == rhs.kind &&
    lhs.span == rhs.span &&
    lhs.meta == rhs.meta &&
    lhs.items == rhs.items
}
