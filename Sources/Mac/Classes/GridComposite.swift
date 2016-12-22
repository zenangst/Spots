import Brick
import Cocoa

/// A proxy cell that is used for composite views inside other Spotable objects
public class GridComposite: NSCollectionViewItem, Composable {

  /// A required content view, needed because of Composable extensions
  public var contentView: View {
    return view
  }

  open lazy var customView: FlippedView = FlippedView()

  static open var isFlipped: Bool {
    get { return true }
  }

  open override func loadView() {
    view = customView
  }
}
