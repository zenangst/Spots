import Foundation
import Tailor
import Brick

#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif

public struct LayoutTrait: Mappable, DictionaryConvertible, Equatable {

  enum Keys: String {
    case itemSpacing = "item-spacing"
    case lineSpacing = "line-spacing"
    case span = "span"
    case dynamicSpan = "dynamic-span"
  }

  static let rootKey: String = "layout"

  public var contentInset: ContentInset = ContentInset()
  public var sectionInset: SectionInset = SectionInset()
  /// For a vertically scrolling grid, this value represents the minimum spacing between items in the same row. 
  /// For a horizontally scrolling grid, this value represents the minimum spacing between items in the same column.
  public var itemSpacing: Double = 0.0
  /// For a vertically scrolling layout, the value represents the minimum spacing between successive rows. 
  /// For a horizontally scrolling layout, the value represents the minimum spacing between successive columns.
  public var lineSpacing: Double = 0.0
  public var span: Double = 0.0
  public var dynamicSpan: Bool = false

  public var dictionary: [String : Any] {
    return [LayoutTrait.rootKey:
      [
        ContentInset.rootKey: contentInset.dictionary,
        SectionInset.rootKey: sectionInset.dictionary,
        Keys.itemSpacing.rawValue: itemSpacing,
        Keys.lineSpacing.rawValue: lineSpacing,
        Keys.span.rawValue: span,
        Keys.dynamicSpan.rawValue: dynamicSpan
      ]
    ]
  }

  public init(_ map: [String : Any] = [:]) {
    self.sectionInset = SectionInset(map)
    self.contentInset = ContentInset(map)
    self.itemSpacing <- map.property(Keys.itemSpacing.rawValue)
    self.lineSpacing <- map.property(Keys.lineSpacing.rawValue)
    self.dynamicSpan <- map.property(Keys.dynamicSpan.rawValue)
  }

  public mutating func configure(withJSON JSON: [String : Any]) {
    self.contentInset.configure(withJSON: JSON)
    self.sectionInset.configure(withJSON: JSON)
    self.itemSpacing <- JSON.property(Keys.itemSpacing.rawValue)
    self.lineSpacing <- JSON.property(Keys.lineSpacing.rawValue)
    self.dynamicSpan <- JSON.property(Keys.dynamicSpan.rawValue)
  }

  public func mutate(_ closure: (inout LayoutTrait) -> Void) -> LayoutTrait {
    var copy = self
    closure(&copy)
    return copy
  }

  public func configure(spot: Listable) {
    contentInset.configure(scrollView: spot.render())
  }

  public static func == (lhs: LayoutTrait, rhs: LayoutTrait) -> Bool {
    return lhs.contentInset == rhs.contentInset &&
    lhs.sectionInset == rhs.sectionInset
  }
}
