import Foundation
import Tailor
import Brick

#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif

public struct Layout: Mappable, DictionaryConvertible, Equatable {

  enum Key: String {
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
    return [
      ContentInset.rootKey: contentInset.dictionary,
      SectionInset.rootKey: sectionInset.dictionary,
      Key.itemSpacing.rawValue: itemSpacing,
      Key.lineSpacing.rawValue: lineSpacing,
      Key.span.rawValue: span,
      Key.dynamicSpan.rawValue: dynamicSpan
    ]
  }

  public init() {
    self.span = 0.0
    self.dynamicSpan = false
    self.itemSpacing = 0.0
    self.lineSpacing = 0.0
    self.sectionInset = SectionInset()
    self.contentInset = ContentInset()
  }

  public init(span: Double = 0.0, dynamicSpan: Bool = false, itemSpacing: Double = 0.0, lineSpacing: Double = 0.0, sectionInset: SectionInset = SectionInset(), contentInset: ContentInset = ContentInset()) {
    self.span = span
    self.dynamicSpan = dynamicSpan
    self.itemSpacing = itemSpacing
    self.lineSpacing = lineSpacing
    self.sectionInset = sectionInset
    self.contentInset = contentInset
  }

  public init(_ map: [String : Any] = [:]) {
    switch Component.legacyMapping {
    case true:
      self.sectionInset = SectionInset(map)
      self.contentInset = ContentInset(map)
    case false:
      self.sectionInset = SectionInset(map.property(SectionInset.rootKey) ?? [:])
      self.contentInset = ContentInset(map.property(ContentInset.rootKey) ?? [:])
    }

    self.itemSpacing <- map.property(Key.itemSpacing.rawValue)
    self.lineSpacing <- map.property(Key.lineSpacing.rawValue)
    self.dynamicSpan <- map.property(Key.dynamicSpan.rawValue)
    self.span <- map.property(Key.span.rawValue)
  }

  public init(_ block: (inout Layout) -> Void) {
    self.init([:])
    block(&self)
  }

  public mutating func configure(withJSON map: [String : Any]) {
    switch Component.legacyMapping {
    case true:
      self.sectionInset = SectionInset(map)
      self.contentInset = ContentInset(map)
    case false:
      self.sectionInset = SectionInset(map.property(SectionInset.rootKey) ?? [:])
      self.contentInset = ContentInset(map.property(ContentInset.rootKey) ?? [:])
    }

    self.itemSpacing <- map.property(Key.itemSpacing.rawValue)
    self.lineSpacing <- map.property(Key.lineSpacing.rawValue)
    self.dynamicSpan <- map.property(Key.dynamicSpan.rawValue)
    self.span <- map.property(Key.span.rawValue)
  }

  public func mutate(_ closure: (inout Layout) -> Void) -> Layout {
    var copy = self
    closure(&copy)
    return copy
  }

  public func configure(spot: Listable) {
    contentInset.configure(scrollView: spot.render())
  }

  public static func == (lhs: Layout, rhs: Layout) -> Bool {
    return lhs.contentInset == rhs.contentInset &&
    lhs.sectionInset == rhs.sectionInset &&
    lhs.itemSpacing == rhs.itemSpacing &&
    lhs.lineSpacing == rhs.lineSpacing &&
    lhs.span == rhs.span &&
    lhs.dynamicSpan == rhs.dynamicSpan
  }

  public static func != (lhs: Layout, rhs: Layout) -> Bool {
    return !(lhs == rhs)
  }
}
