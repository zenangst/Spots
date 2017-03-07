import UIKit

// MARK: - An extension on Composable views
public extension Composable where Self : View {

  /// A configuration method to configure the Composable view with a collection of CoreComponent objects
  ///
  ///  - parameter item:  The item that is currently being configured in the list
  ///  - parameter components: A collection of CoreComponent objects created from the children of the item
  func configure(_ item: inout Item, compositeComponents: [CompositeComponent]?) {
    guard let compositeComponents = compositeComponents else {
      return
    }

    var size = contentView.frame.size
    let width = contentView.frame.width
    var height: CGFloat = 0.0

    #if os(tvOS)
      if let tableView = superview?.superview as? UITableView {
        size.width = tableView.frame.size.width
      }
    #endif

    compositeComponents.enumerated().forEach { _, compositeSpot in
      compositeSpot.component.setup(size)
      compositeSpot.component.model.size = CGSize(
        width: width,
        height: ceil(compositeSpot.component.view.frame.size.height))
      compositeSpot.component.layout(size)
      compositeSpot.component.view.layoutIfNeeded()

      compositeSpot.component.view.frame.origin.y = height
      /// Disable scrolling for listable objects
      compositeSpot.component.view.isScrollEnabled = !(compositeSpot.component is Listable)
      compositeSpot.component.view.frame.size.height = compositeSpot.component.view.contentSize.height

      height += compositeSpot.component.view.contentSize.height

      contentView.addSubview(compositeSpot.component.view)
    }

    item.size.height = height
  }
}
