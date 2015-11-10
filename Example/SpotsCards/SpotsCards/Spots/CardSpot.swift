import UIKit

public class CardSpot: CarouselSpot {

  public required init(component: Component) {
    super.init(component: component)

    flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    flowLayout.minimumLineSpacing = 0
  }

}
