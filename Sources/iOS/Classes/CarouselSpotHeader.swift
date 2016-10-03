import UIKit

class CarouselSpotHeader: UICollectionReusableView, Componentable {

  var defaultHeight: CGFloat = 120

  lazy var titleLabel = UILabel()

  override init(frame: CGRect) {
    super.init(frame: frame)

    addSubview(titleLabel)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(_ component: Component) {
    titleLabel.text = component.title
  }

}
