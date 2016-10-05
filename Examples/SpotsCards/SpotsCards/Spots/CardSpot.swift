import UIKit
import Spots

open class CardSpot: CarouselSpot {

  static let padding: CGFloat = 25

  public required init(component: Component) {
    super.init(component: component)

    layout.sectionInset = UIEdgeInsets(top: 0, left: CardSpot.padding, bottom: 0, right: CardSpot.padding)
    layout.minimumLineSpacing = -10
  }

}
