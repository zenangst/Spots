import UIKit
import Sugar
import Brick

class GridSpotCell: UICollectionViewCell, SpotConfigurable {

  var size = CGSize(width: 88, height: 88)
  var item: ViewModel?

  var label = UILabel().then {
    $0.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
    $0.textAlignment = .Center
    $0.autoresizingMask = [.FlexibleWidth]
  }

  lazy var imageView = UIImageView().then {
    $0.contentMode = .ScaleAspectFill
    $0.autoresizingMask = [.FlexibleWidth]
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    [imageView, label].forEach { contentView.addSubview($0) }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(inout item: ViewModel) {
    imageView.image = UIImage(named: item.image)
    imageView.frame = contentView.frame
    label.text = item.title
  }
}
