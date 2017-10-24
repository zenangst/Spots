import Foundation

#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif

/// A layout struct used for mapping layout to a component.
public struct Layout: Codable, Equatable {

  /// A string based enum for keys used when encoding and decoding the struct from and to JSON.
  ///
  /// - itemSpacing: Used to set `minimumInteritemSpacing` on collection view based UI.
  /// - lineSpacing: Used to set `minimumLineSpacing` on collection view based UI.
  /// - span: Used to set which span the component should use.
  /// - dynamicSpan: Used to map dynamic span.
  /// - dynamicHeight: Used to map if component should use dynamic height.
  /// - pageIndicator: Used to map if component should display a page indicator.
  enum Key: String, CodingKey {
    case inset
    case itemSpacing = "item-spacing"
    case lineSpacing = "line-spacing"
    case itemsPerRow = "items-per-row"
    case span
    case dynamicSpan = "dynamic-span"
    case dynamicHeight = "dynamic-height"
    case pageIndicatorPlacement = "page-indicator"
    case headerMode = "header-mode"
    case infiniteScrolling = "infinite-scrolling"
    case showEmptyComponent = "show-empty-component"
  }

  public var inset: Inset = Inset()
  /// For a vertically scrolling grid, this value represents the minimum spacing between items in the same row.
  /// For a horizontally scrolling grid, this value represents the minimum spacing between items in the same column.
  public var itemSpacing: Double = 0.0
  /// For a vertically scrolling layout, the value represents the minimum spacing between successive rows.
  /// For a horizontally scrolling layout, the value represents the minimum spacing between successive columns.
  public var lineSpacing: Double = 0.0

  /// Items per row is used in horizontal `Component`'s to configure how many items should be displayed
  /// in per row. It defaults two 1, which means that all items end up on the same row.
  /// 
  /// Example with `itemsPerRow` set to 1.
  /// |item 1|item 2|item 3|item 4|
  ///
  /// Example with `itemsPerRow` set to 2.
  /// |item 1|item 3|
  /// |item 2|item 4|
  public var itemsPerRow: Int = 1
  /// Defines how many items to show per row for `Gridable` components.
  public var span: Double = 0.0
  /// If enabled and the item count is less than the span, the CarouselComponent will even out the space between the items to align them.
  public var dynamicSpan: Bool = false
  /// Defines if the component uses computed content height or relies on `view.frame.height`.
  public var dynamicHeight: Bool = true
  /// The placement of any page indicator (`nil` if no indicator should be displayed)
  public var pageIndicatorPlacement: PageIndicatorPlacement?
  /// Header stickiness
  public var headerMode: HeaderMode = .default
  /// Infinite scrolling behavior for horizontal collection views.
  /// When enabled, the data source gets padded with index paths to create the
  /// illusion that the component goes to infinity. When it does get to the
  /// end it will jump to the beginning of the content offset and vice versa.
  /// See `Component.handleInfiniteScrolling()` for more information.
  /// Note: Only available iOS and tvOS. 
  public var infiniteScrolling: Bool = false
  /// If the `ComponentModel` is empty, it should still be shown.
  public var showEmptyComponent: Bool = false

  /// A convenience initializer with default values.
  public init() {}

  /// Default initializer for creating a Layout struct.
  ///
  /// - Parameters:
  ///   - span: The span that should be used for the model.
  ///   - dynamicSpan: Enable or disable dynamic span.
  ///   - dynamicHeight: Enable or disable dynamic height.
  ///   - pageIndicatorPlacement: Where any page indicator (if any) should be displayed in the model.
  ///   - itemSpacing: Sets minimum item spacing for the model.
  ///   - lineSpacing: Sets minimum lines spacing for items in model.
  ///   - inset: An inset struct used to insert margins for the model.
  public init(span: Double = 0.0,
              dynamicSpan: Bool = false,
              dynamicHeight: Bool = true,
              pageIndicatorPlacement: PageIndicatorPlacement? = nil,
              itemsPerRow: Int = 1,
              itemSpacing: Double = 0.0,
              lineSpacing: Double = 0.0,
              inset: Inset = .init(),
              headerMode: HeaderMode = .default,
              showEmptyComponent: Bool = false,
              infiniteScrolling: Bool = false) {
    self.span = span
    self.dynamicSpan = dynamicSpan
    self.dynamicHeight = dynamicHeight
    self.itemSpacing = itemSpacing
    self.itemsPerRow = itemsPerRow
    self.lineSpacing = lineSpacing
    self.inset = inset
    self.pageIndicatorPlacement = pageIndicatorPlacement
    self.headerMode = headerMode
    self.showEmptyComponent = showEmptyComponent
    self.infiniteScrolling = infiniteScrolling
  }

  public init(_ block: (inout Layout) -> Void) {
    self.init()
    block(&self)
  }

  /// Initialize with a decoder.
  ///
  /// - Parameter decoder: A decoder that can decode values into in-memory representations.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Key.self)
    self.inset = try container.decodeIfPresent(Inset.self, forKey: .inset) ?? Inset()
    self.itemSpacing = try container.decodeIfPresent(Double.self, forKey: .itemSpacing) ?? 0.0
    self.lineSpacing = try container.decodeIfPresent(Double.self, forKey: .lineSpacing) ?? 0.0
    self.itemsPerRow = try container.decodeIfPresent(Int.self, forKey: .itemsPerRow) ?? 1
    self.span = try container.decodeIfPresent(Double.self, forKey: .span) ?? 0.0
    self.dynamicSpan = try container.decodeIfPresent(Bool.self, forKey: .dynamicSpan) ?? false
    self.dynamicHeight = try container.decodeIfPresent(Bool.self, forKey: .dynamicHeight) ?? true
    self.pageIndicatorPlacement = try container.decodeIfPresent(PageIndicatorPlacement.self,
                                                                forKey: .pageIndicatorPlacement)
    self.headerMode = try container.decodeIfPresent(HeaderMode.self, forKey: .headerMode) ?? .default
    self.infiniteScrolling = try container.decodeIfPresent(Bool.self, forKey: .infiniteScrolling) ?? false
    self.showEmptyComponent = try container.decodeIfPresent(Bool.self, forKey: .showEmptyComponent) ?? false
  }

  /// Perform mutation with closure.
  ///
  /// - Parameter closure: A mutation closure used to change values for a layout.
  /// - Returns: A mutated Layout struct.
  public func mutate(_ closure: (inout Layout) -> Void) -> Layout {
    var copy = self
    closure(&copy)
    return copy
  }

  /// Compare Layout structs.
  ///
  /// - Parameters:
  ///   - lhs: Left hand side Layout
  ///   - rhs: Right hand side Layout
  /// - Returns: A boolean value that is true if all properties are equal on the struct.
  public static func == (lhs: Layout, rhs: Layout) -> Bool {
    return lhs.inset == rhs.inset &&
    lhs.itemSpacing == rhs.itemSpacing &&
    lhs.itemsPerRow == rhs.itemsPerRow &&
    lhs.lineSpacing == rhs.lineSpacing &&
    lhs.span == rhs.span &&
    lhs.dynamicSpan == rhs.dynamicSpan &&
    lhs.dynamicHeight == rhs.dynamicHeight &&
    lhs.pageIndicatorPlacement == rhs.pageIndicatorPlacement &&
    lhs.showEmptyComponent == rhs.showEmptyComponent &&
    lhs.headerMode == rhs.headerMode &&
    lhs.infiniteScrolling == rhs.infiniteScrolling
  }

  /// Compare Layout structs.
  ///
  /// - Parameters:
  ///   - lhs: Left hand side Layout
  ///   - rhs: Right hand side Layout
  /// - Returns: A boolean value that is true if all properties are not equal on the struct.
  public static func != (lhs: Layout, rhs: Layout) -> Bool {
    return !(lhs == rhs)
  }
}
