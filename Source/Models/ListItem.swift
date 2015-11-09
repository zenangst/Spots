import Tailor
import Sugar

public protocol Listable { }

public struct ListSize {
  public var height: CGFloat
  public var width: CGFloat

  init(width: CGFloat = 0, height: CGFloat = 0) {
    self.width = width
    self.height = height
  }
}

public struct ListItem: Mappable, Listable {
  public var title = ""
  public var subtitle = ""
  public var image = ""
  public var kind = ""
  public var urn: String?
  public var size = ListSize()
  public var meta = [String : AnyObject]()

  public init(_ map: JSONDictionary) {
    title    <- map.property("title")
    subtitle <- map.property("subtitle")
    image    <- map.property("image")
    kind     <- map.property("type")
    urn      <- map.property("urn")
    size     <- map.property("size")
    meta     <- map.property("meta")
  }

  public init(title: String, subtitle: String = "", image: String = "", kind: String = "", urn: String? = "", size: ListSize = ListSize(), meta: [String : String] = [:]) {
    self.title = title
    self.subtitle = subtitle
    self.image = image
    self.kind = kind
    self.urn = urn
    self.size = size
    self.meta = meta
  }
}
