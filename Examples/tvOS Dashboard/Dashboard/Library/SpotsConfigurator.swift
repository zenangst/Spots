import Foundation
import Spots
import Brick

enum Cell: String, StringConvertible {
  case List, Featured, Grid

  var string: String {
    return rawValue
  }
}

struct SpotsConfigurator {

  func configure() {
    CarouselSpot.register(FeaturedCell.self, identifier: Cell.Featured)
    GridSpot.register(GridCell.self, identifier: Cell.Grid)
    ListSpot.register(ListCell.self, identifier: Cell.List)

    ListSpot.register(defaultView: ListCell.self)
    GridSpot.register(defaultView: GridCell.self)
    CarouselSpot.register(defaultView: GridCell.self)

    SpotsController.configure = {
      $0.backgroundColor = UIColor.clear
    }

    GridSpot.configure = { collectionView, layout in
      collectionView.backgroundColor = UIColor.clear
      collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }

    CarouselSpot.configure = { collectionView, layout in
      collectionView.backgroundColor = UIColor.clear
      collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }

    ListSpot.configure = {
      $0.backgroundColor = UIColor.clear
      $0.tableFooterView = UIView(frame: CGRect.zero)
    }
  }
}
