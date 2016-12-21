import Brick
import Cocoa

/// A proxy cell that is used for composite views inside other Spotable objects
public class GridComposite: NSCollectionViewItem, Composable {

  /// A required content view, needed because of Composable extensions
  public var contentView: View {
    return view
  }

  open var customView = FlippedView()

  static open var isFlipped: Bool {
    get {
      return true
    }
  }

  override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nil, bundle: nil)
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open override func loadView() {
    view = customView
  }

  /// A configuration method to configure the Composable view with a collection of Spotable objects
  ///
  ///  - parameter item:  The item that is currently being configured in the list
  ///  - parameter spots: A collection of Spotable objects created from the children of the item
  public func configure(_ item: inout Item, spots: [Spotable]?) {
    guard let spots = spots else { return }

    var height: CGFloat = 0.0

    spots.enumerated().forEach { index, spot in
      spot.component.size = CGSize(
        width: view.frame.width,
        height: ceil(spot.render().frame.size.height))

      spot.component.size?.height == Optional(0.0)
        ? spot.setup(view.frame.size)
        : spot.layout(view.frame.size)

      view.addSubview(spot.render())
      spot.render().frame.origin.y = height
      height += spot.render().contentSize.height
    }

    item.size.height = height
  }
}
