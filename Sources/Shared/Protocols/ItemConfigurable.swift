import CoreGraphics

/**
  A class protocol that requires configure(item: Item), it can be applied to UI components to annotate that they are intended to use Item.
 */
public protocol ItemConfigurable: class {

  /// The perferred view size of the view.
  var preferredViewSize: CGSize { get }

  /**
   A configure method that is used on reference types that can be configured using a view model

   - parameter item: A inout Item so that the ItemConfigurable object can configure the view model width and height based on its UI components
  */
  func configure(_ item: inout ContentModel)

  func prepareForReuse()
}
