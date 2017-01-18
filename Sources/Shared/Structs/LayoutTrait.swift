import Foundation
import Tailor
import Brick

public struct LayoutTrait: Mappable, DictionaryConvertible {

  static let rootKey: String = "layout"

  public var contentInset: ContentInset = ContentInset()
  public var sectionInset: SectionInset = SectionInset()
  public var minimumInteritemSpacing: Double = 0.0
  public var minimumLineSpacing: Double = 0.0

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
}
