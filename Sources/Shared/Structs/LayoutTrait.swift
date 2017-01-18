import Foundation
import Tailor
import Brick

#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif

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
