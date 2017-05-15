#if os(macOS)
  import Cocoa
#else
  import UIKit
#endif

/// When a view conforms to `DynamicSizeView`, the size cache will use the value
/// from `computedSize` instead of relying on the `preferredViewSize`.
/// `computedSize` is called directly after `configure(with item: Item)`.
public protocol DynamicSizeView {

  /// Returns the computed size for the view.
  /// It can be used to dynamically size views based of the model data.
  ///
  /// Usage:
  ///
  /// ```
  /// func computeSize(for item: Item) -> CGSize  {
  ///   return textLabel.sizeThatFits(item.size)
  /// }
  /// ```
  ///
  /// - Parameter item: The item model for the view.
  /// - Returns: A `CGSize` that gets passed back to `SizeCache`.
  func computeSize(for item: Item) -> CGSize
}
