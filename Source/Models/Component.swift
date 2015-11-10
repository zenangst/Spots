import Tailor
import Sugar

public struct ComponentSize {
  public var height: CGFloat
  public var width: CGFloat

  init(width: CGFloat = 0, height: CGFloat = 0) {
    self.width = width
    self.height = height
  }

  func coreGraphicsSize() -> CGSize {
    return CGSize(width: self.width, height: self.height)
  }
}

public struct Component: Mappable {
  public var title = ""
  public var kind = ""
  public var span = 1
  public var items = [ListItem]()
  public var size: ComponentSize?
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

func ==(lhs: Component, rhs: Component) -> Bool {
  return lhs.title == rhs.title && lhs.kind == rhs.kind && lhs.span == rhs.span && lhs.meta == rhs.meta
}
