import UIKit

public class SpotsContentView : UIView {

  override public func didAddSubview(subview: UIView) {
    super.didAddSubview(subview)

    if let containerScrollView = superview as? SpotsScrollView {
      containerScrollView.didAddSubviewToContainer(subview)
    }
  }

  override public func willRemoveSubview(subview: UIView) {
    super.willRemoveSubview(subview)

    if let containerScrollView = superview as? SpotsScrollView {
      containerScrollView.willRemoveSubview(subview)
    }
  }
}
