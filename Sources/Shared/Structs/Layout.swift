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
    case dynamicHeight = "dynamic-height"
    case pageIndicator = "page-indicator"
  }

  static let rootKey: String = String(describing: Layout.self).lowercased()

  public var inset: Inset = Inset()
  /// For a vertically scrolling grid, this value represents the minimum spacing between items in the same row.
  /// For a horizontally scrolling grid, this value represents the minimum spacing between items in the same column.
  public var itemSpacing: Double = 0.0
  /// For a vertically scrolling layout, the value represents the minimum spacing between successive rows. 
  /// For a horizontally scrolling layout, the value represents the minimum spacing between successive columns.
  public var lineSpacing: Double = 0.0
  public var span: Double = 0.0
  public var dynamicSpan: Bool = false
  public var dynamicHeight: Bool = true
  public var pageIndicator: Bool = false

  public var dictionary: [String : Any] {
    return [
      Inset.rootKey: inset.dictionary,
      Key.itemSpacing.rawValue: itemSpacing,
      Key.lineSpacing.rawValue: lineSpacing,
      Key.span.rawValue: span,
      Key.dynamicSpan.rawValue: dynamicSpan,
      Key.dynamicHeight.rawValue: dynamicHeight,
      Key.pageIndicator.rawValue: pageIndicator
    ]
  }

  public init() {
    self.span = 0.0
    self.dynamicSpan = false
    self.itemSpacing = 0.0
    self.lineSpacing = 0.0
    self.pageIndicator = false
    self.inset = Inset()
  }

  public init(span: Double = 0.0, dynamicSpan: Bool = false, dynamicHeight: Bool = true, pageIndicator: Bool = false, itemSpacing: Double = 0.0, lineSpacing: Double = 0.0, inset: Inset = Inset()) {
    self.span = span
    self.dynamicSpan = dynamicSpan
    self.dynamicHeight = dynamicHeight
    self.itemSpacing = itemSpacing
    self.lineSpacing = lineSpacing
    self.inset = inset
    self.pageIndicator = pageIndicator
  }

  public init(_ map: [String : Any] = [:]) {
    configure(withJSON: map)
  }

  public init(_ block: (inout Layout) -> Void) {
    self.init([:])
    block(&self)
  }

  public mutating func configure(withJSON map: [String : Any]) {
    switch Component.legacyMapping {
    case true:
      self.inset = Inset(map)
    case false:
      self.inset = Inset(map.property(Inset.rootKey) ?? [:])
    }

    self.itemSpacing <- map.property(Key.itemSpacing.rawValue)
    self.lineSpacing <- map.property(Key.lineSpacing.rawValue)
    self.dynamicSpan <- map.property(Key.dynamicSpan.rawValue)
    self.dynamicHeight <- map.property(Key.dynamicHeight.rawValue)
    self.span <- map.property(Key.span.rawValue)
    self.pageIndicator <- map.property(Key.pageIndicator.rawValue)
  }

  public func mutate(_ closure: (inout Layout) -> Void) -> Layout {
    var copy = self
    closure(&copy)
    return copy
  }

  public func configure(spot: Listable) {
    inset.configure(scrollView: spot.view)
  }

  public static func == (lhs: Layout, rhs: Layout) -> Bool {
    return lhs.inset == rhs.inset &&
    lhs.itemSpacing == rhs.itemSpacing &&
    lhs.lineSpacing == rhs.lineSpacing &&
    lhs.span == rhs.span &&
    lhs.dynamicSpan == rhs.dynamicSpan &&
    lhs.dynamicHeight == rhs.dynamicHeight &&
    lhs.pageIndicator == rhs.pageIndicator
  }

  public static func != (lhs: Layout, rhs: Layout) -> Bool {
    return !(lhs == rhs)
  }
}
