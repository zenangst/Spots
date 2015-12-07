import UIKit

public class SpotCell: UICollectionViewCell {

  var spot: Spotable?

  public var spotView: UIView? {
    didSet {
      guard let spotView = spotView else { return }
      contentView.addSubview(spotView)
    }
  }

  public override init(frame: CGRect) {
    super.init(frame: frame)
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
