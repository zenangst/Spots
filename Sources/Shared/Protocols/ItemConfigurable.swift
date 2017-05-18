import CoreGraphics

/**
  A class protocol that requires configure(item: Item), it can be applied to UI components to annotate that they are intended to use Item.
 */
public protocol ItemConfigurable: class {

  /**
   A configure method that is used on reference types that can be configured using a view model

   - parameter item: A inout Item so that the ItemConfigurable object can configure the view model width and height based on its UI components
  */
  func configure(with item: Item)

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
  /// - Returns: A `CGSize` that gets passed back to the data source.
  func computeSize(for item: Item) -> CGSize

  func prepareForReuse()
}
