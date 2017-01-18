import Foundation
import Tailor
import Brick

public struct LayoutTrait: Mappable, DictionaryConvertible, Equatable {

  enum Keys: String {
    case itemSpacing = "item-spacing"
    case lineSpacing = "line-spacing"
    case span = "span"
  }

  static let rootKey: String = "layout"

  public var contentInset: ContentInset = ContentInset()
  public var sectionInset: SectionInset = SectionInset()
  public var itemMargin: Double = 0.0
  public var lineSpacing: Double = 0.0
  public var span: Double = 0.0

  public var dictionary: [String : Any] {
    return [LayoutTrait.rootKey:
      [
        ContentInset.rootKey: contentInset.dictionary,
        SectionInset.rootKey: sectionInset.dictionary,
        Keys.itemSpacing.rawValue: itemMargin,
        Keys.lineSpacing.rawValue: lineSpacing,
        Keys.span.rawValue: span
      ]
    ]
  }

  public init(_ map: [String : Any] = [:]) {
    self.sectionInset = SectionInset(map)
    self.contentInset = ContentInset(map)
    self.itemMargin <- map.property(GridableMeta.Key.minimumInteritemSpacing)
    self.lineSpacing <- map.property(GridableMeta.Key.minimumLineSpacing)
  }

  public mutating func configure(withJSON JSON: [String : Any]) {
    self.contentInset.configure(withJSON: JSON)
    self.sectionInset.configure(withJSON: JSON)
    self.itemMargin <- JSON.property(GridableMeta.Key.minimumInteritemSpacing)
    self.lineSpacing <- JSON.property(GridableMeta.Key.minimumLineSpacing)
  }

  public func mutate(_ closure: (inout LayoutTrait) -> Void) -> LayoutTrait {
    var copy = self
    closure(&copy)
    return copy
  }

  public func configure(spot: Gridable) {
    sectionInset.configure(layout: spot.layout)
    contentInset.configure(scrollView: spot.render())
  }

  public func configure(spot: Listable) {
    contentInset.configure(scrollView: spot.render())
  }

  public static func == (lhs: LayoutTrait, rhs: LayoutTrait) -> Bool {
    return lhs.contentInset == rhs.contentInset &&
    lhs.sectionInset == rhs.sectionInset
  }
}
