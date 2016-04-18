#if os(iOS)
  import UIKit
#else
  import Foundation
#endif

import Tailor
import Sugar
import Brick

public struct Component: Mappable {
  public var index = 0
  public var title = ""
  public var kind = ""
  public var span: CGFloat = 0
  public var items = [ViewModel]()
  public var size: CGSize?
  public var meta = [String : AnyObject]()

  public init(_ map: JSONDictionary) {
    title <- map.property("title")
    kind  <- map.property("type")
    span  <- map.property("span")
    items <- map.relations("items")
    meta  <- map.property("meta")
  }

  public init(title: String = "", kind: String = "", span: CGFloat = 0, items: [ViewModel] = [], meta: [String : AnyObject] = [:]) {
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
    (lhs.meta as NSDictionary).isEqual(rhs.meta as NSDictionary) &&
    lhs.items == rhs.items
}
