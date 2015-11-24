import UIKit
import Tailor
import Sugar

public struct ListItem: Mappable {
  public var index = 0
  public var title = ""
  public var subtitle = ""
  public var image = ""
  public var kind = ""
  public var action: String?
  public var size = CGSize(width: 0, height: 0)
  public var meta = [String : AnyObject]()

  public init(_ map: JSONDictionary) {
    title    <- map.property("title")
    subtitle <- map.property("subtitle")
    image    <- map.property("image")
    kind     <- map.property("type")
    action   <- map.property("action")
    meta     <- map.property("meta")

    size = CGSize(
      width:  ((map["size"] as? JSONDictionary)?["width"] as? Int) ?? 0,
      height: ((map["size"] as? JSONDictionary)?["width"] as? Int) ?? 0
    )
  }

  public init(title: String, subtitle: String = "", image: String = "", kind: String = "", action: String? = nil, size: CGSize = CGSize(width: 0, height: 0), meta: JSONDictionary = [:]) {
    self.title = title
    self.subtitle = subtitle
    self.image = image
    self.kind = kind
    self.action = action
    self.size = size
    self.meta = meta
  }
}

func ==(lhs: ListItem, rhs: ListItem) -> Bool {
  let equal = lhs.title == rhs.title &&
    lhs.subtitle == rhs.subtitle &&
    lhs.image == rhs.image &&
    lhs.kind == rhs.kind &&
    lhs.action == rhs.action &&
    lhs.size == rhs.size

  return equal
}

func !=(lhs: ListItem, rhs: ListItem) -> Bool {
  return !(lhs == rhs)
}
