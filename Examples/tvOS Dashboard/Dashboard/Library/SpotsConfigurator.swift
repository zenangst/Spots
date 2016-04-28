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
    CarouselSpot.views[Cell.Featured] = FeaturedCell.self
    GridSpot.views[Cell.Grid] = GridCell.self
    ListSpot.views[Cell.List] = ListCell.self

    ListSpot.defaultKind = Cell.List.string
    GridSpot.defaultKind = Cell.Grid.string
    CarouselSpot.defaultKind = Cell.Grid.string

    SpotsController.configure = {
      $0.backgroundColor = UIColor.clearColor()
    }

    GridSpot.configure = { collectionView, layout in
      collectionView.backgroundColor = UIColor.clearColor()
      collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }

    CarouselSpot.configure = { collectionView, layout in
      collectionView.backgroundColor = UIColor.clearColor()
      collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }

    ListSpot.configure = {
      $0.backgroundColor = UIColor.clearColor()
      $0.tableFooterView = UIView(frame: CGRect.zero)
    }
  }
}
