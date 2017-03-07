import UIKit

/// A proxy cell that is used for composite views inside other CoreComponent objects
public class ListComposite: UITableViewCell, Composable {

  /// Performs any clean up necessary to prepare the view for use again.
  public override func prepareForReuse() {
    for case let view as ScrollableView in contentView.subviews {
      view.removeFromSuperview()
    }
  }

  override public var canBecomeFocused: Bool {
    return false
  }

  /// This methods fixes which view should become the next responder when navigating between views on tvOS.
  #if os(tvOS)
  public override func didMoveToSuperview() {
    superview?.sendSubview(toBack: self)
  }
  #endif
}
