import UIKit

public class SpotsContentView : UIView {

  override public func didAddSubview(subview: UIView) {
    super.didAddSubview(subview)

    guard let containerScrollView = superview as? SpotsScrollView else { return }
    containerScrollView.didAddSubviewToContainer(subview)
  }

  override public func willRemoveSubview(subview: UIView) {
    super.willRemoveSubview(subview)

    guard let containerScrollView = superview as? SpotsScrollView else { return }
    containerScrollView.willRemoveSubview(subview)
  }
}
