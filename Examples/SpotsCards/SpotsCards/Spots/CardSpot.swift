import UIKit
import Spots

public class CardSpot: CarouselSpot {

  public required init(component: Component) {
    super.init(component: component)

    layout.sectionInset = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
    layout.minimumLineSpacing = -10
  }

}
