import Cocoa

// MARK: - An extension on Composable views
public extension Composable {

  /// A configuration method to configure the Composable view with a collection of components.
  ///
  ///  - parameter item:  The item that is currently being configured in the list
  ///  - parameter components: A collection of components. created from the children of the item
  func configure(_ item: inout Item, compositeComponents: [CompositeComponent]?) {
    guard let compositeComponents = compositeComponents else {
      return
    }

    let size = contentView.frame.size
    var height: CGFloat = 0.0

    compositeComponents.enumerated().forEach { _, compositeSpot in
      compositeSpot.component.layout(with: size)
      height = compositeSpot.component.computedHeight
      contentView.addSubview(compositeSpot.component.view)
      compositeSpot.component.collectionView?.collectionViewLayout?.invalidateLayout()
    }

    item.size.height = height
  }

  /// Parse view model children into components.
  /// - parameter item: A view model with children
  ///
  ///  - returns: A collection of components.
  public func parse(_ item: Item) -> [Component] {
    let components = Parser.parse(item.children)
    return components
  }
}
