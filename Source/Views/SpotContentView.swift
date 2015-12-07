import UIKit

public class SpotContentView : UIView {

  override public func didAddSubview(subview: UIView) {
    super.didAddSubview(subview)

    if let containerScrollView = superview as? SpotScrollView {
      containerScrollView.didAddSubviewToContainer(subview)
    }
  }

  override public func willRemoveSubview(subview: UIView) {
    super.willRemoveSubview(subview)

    if let containerScrollView = superview as? SpotScrollView {
      containerScrollView.willRemoveSubview(subview)
    }
  }
}
