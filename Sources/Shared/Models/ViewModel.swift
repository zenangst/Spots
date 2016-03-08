#if os(iOS)
  import UIKit
#else
  import Foundation
#endif

import Tailor
import Sugar

public struct ViewModel: Mappable {
  public var index = 0
  public var title = ""
  public var subtitle = ""
  public var image = ""
  public var kind = ""
  public var action: String?
  public var size = CGSize(width: 0, height: 0)
  public var meta = [String : AnyObject]()
  public var relations = [String : [ViewModel]]()

  public init(_ map: JSONDictionary) {
    title    <- map.property("title")
    subtitle <- map.property("subtitle")
    image    <- map.property("image")
    kind     <- map.property("type")
    action   <- map.property("action")
    meta     <- map.property("meta")

    if let relation = map["relations"] as? [String : [ViewModel]] {
      relations = relation
    }

    if let relations = map["relations"] as? [String : [JSONDictionary]] {
      var newRelations = [String : [ViewModel]]()
      relations.forEach { key, array in
        if newRelations[key] == nil { newRelations[key] = [ViewModel]() }
        array.forEach { newRelations[key]?.append(ViewModel($0)) }

        self.relations = newRelations
      }
    }

    size = CGSize(
      width:  ((map["size"] as? JSONDictionary)?["width"] as? Int) ?? 0,
      height: ((map["size"] as? JSONDictionary)?["height"] as? Int) ?? 0
    )
  }

  public init(title: String = "", subtitle: String = "", image: String = "", kind: String = "", action: String? = nil, size: CGSize = CGSize(width: 0, height: 0), meta: JSONDictionary = [:], relations: [String : [ViewModel]] = [:]) {
    self.title = title
    self.subtitle = subtitle
    self.image = image
    self.kind = kind
    self.action = action
    self.size = size
    self.meta = meta
    self.relations = relations
  }

  public func meta<T>(key: String, _ defaultValue: T) -> T {
    return meta[key] as? T ?? defaultValue
  }

  public func meta<T>(key: String, type: T.Type) -> T? {
    return meta[key] as? T
  }

  public func relation(key: String, _ index: Int) -> ViewModel? {
    if let items = relations[key] where index < items.count {
      return items[index]
    } else {
      return nil
    }
  }
}

public func ==(lhs: [ViewModel], rhs: [ViewModel]) -> Bool {
  var equal = lhs.count == rhs.count

  if !equal { return false }

  for (index, item) in lhs.enumerate() {
    if item != rhs[index] { equal = false; break }
  }

  return equal
}

public func ==(lhs: ViewModel, rhs: ViewModel) -> Bool {
  let equal = lhs.title == rhs.title &&
    lhs.subtitle == rhs.subtitle &&
    lhs.image == rhs.image &&
    lhs.kind == rhs.kind &&
    lhs.action == rhs.action

  return equal
}

public func ===(lhs: ViewModel, rhs: ViewModel) -> Bool {
  let equal = lhs.title == rhs.title &&
    lhs.subtitle == rhs.subtitle &&
    lhs.image == rhs.image &&
    lhs.kind == rhs.kind &&
    lhs.action == rhs.action &&
    lhs.size == rhs.size

  return equal
}

public func !=(lhs: ViewModel, rhs: ViewModel) -> Bool {
  return !(lhs == rhs)
}
