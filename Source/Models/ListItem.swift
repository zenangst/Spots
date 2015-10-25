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
  public var uri: String?
  public var size = ListSize()
  public var meta = [String : AnyObject]()

  public init(_ map: JSONDictionary) {
    title    <- map.property("title")
    subtitle <- map.property("subtitle")
    image    <- map.property("image")
    kind     <- map.property("type")
    uri      <- map.property("uri")
    size     <- map.property("size")
    meta     <- map.property("meta")
  }
}
