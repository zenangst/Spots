import Foundation
import Tailor
import Brick

#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif

struct ContentInset: Mappable, DictionaryConvertible {

  static let rootKey: String = "content-insets"

  var top: Double = 0.0
  var left: Double = 0.0
  var bottom: Double = 0.0
  var right: Double = 0.0

  public var dictionary: [String : Any] {
    return [
      GridableMeta.Key.contentInsetTop    : self.top,
      GridableMeta.Key.contentInsetLeft   : self.left,
      GridableMeta.Key.contentInsetBottom : self.bottom,
      GridableMeta.Key.contentInsetRight  : self.right
    ]
  }

  public init(top: Double = 0.0, left: Double = 0.0, bottom: Double = 0.0, right: Double = 0.0) {
    self.top = top
    self.left = left
    self.bottom = bottom
    self.right = right
  }

  public init(_ map: [String : Any]) {
    self.top    <- map.property(GridableMeta.Key.contentInsetTop)
    self.left   <- map.property(GridableMeta.Key.contentInsetLeft)
    self.bottom <- map.property(GridableMeta.Key.contentInsetBottom)
    self.right  <- map.property(GridableMeta.Key.contentInsetRight)
  }

  public mutating func configure(withJSON JSON: [String : Any]) {
    self.top    <- JSON.property(GridableMeta.Key.contentInsetTop)
    self.left   <- JSON.property(GridableMeta.Key.contentInsetLeft)
    self.bottom <- JSON.property(GridableMeta.Key.contentInsetBottom)
    self.right  <- JSON.property(GridableMeta.Key.contentInsetRight)
  }
}

struct LayoutTrait: Mappable, DictionaryConvertible {

  static let rootKey: String = "layout"

  var contentInset: ContentInset = ContentInset()
  var sectionInset: SectionInset = SectionInset()
  var minimumInteritemSpacing: Double = 0.0
  var minimumLineSpacing: Double = 0.0

  public var dictionary: [String : Any] {
    return [LayoutTrait.rootKey :
      [
        ContentInset.rootKey : contentInset.dictionary,
        SectionInset.rootKey : sectionInset.dictionary,
        "minimumInteritemSpacing" : minimumInteritemSpacing,
        "minimumLineSpacing" : minimumLineSpacing,
      ]
    ]
  }

  public init(_ map: [String : Any]) {
    self.sectionInset = SectionInset(map)
    self.contentInset = ContentInset(map)
    self.minimumInteritemSpacing <- map.property(GridableMeta.Key.minimumInteritemSpacing)
    self.minimumLineSpacing <- map.property(GridableMeta.Key.minimumLineSpacing)
  }

  public mutating func configure(withJSON JSON: [String : Any]) {
    self.contentInset.configure(withJSON: JSON)
    self.sectionInset.configure(withJSON: JSON)
    self.minimumInteritemSpacing <- JSON.property(GridableMeta.Key.minimumInteritemSpacing)
    self.minimumLineSpacing <- JSON.property(GridableMeta.Key.minimumLineSpacing)
  }

  public func configure(layout: CollectionLayout) {

  }
}
