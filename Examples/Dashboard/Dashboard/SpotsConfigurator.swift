import Foundation
import Spots
import Brick

enum Cell: String, StringConvertible {
  case List, Featured

  var string: String {
    return rawValue
  }
}

struct SpotsConfigurator {

  func configure() {
    CarouselSpot.views[Cell.Featured] = GridTopicCell.self
    GridSpot.views[Cell.Featured] = GridTopicCell.self
    ListSpot.views[Cell.List] = ListCell.self
    ListSpot.defaultKind = Cell.List.string

    // Configure spots controller
    SpotsController.configure = {
      $0.backgroundColor = UIColor.clearColor()
    }

    GridSpot.configure = { collectionView, layout in
      collectionView.backgroundColor = UIColor.clearColor()
      collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }

    CarouselSpot.configure = {
      $0.backgroundColor = UIColor.clearColor()
      $0.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }

    // Configure List spots
    ListSpot.configure = {
      $0.backgroundColor = UIColor.clearColor()
      $0.tableFooterView = UIView(frame: CGRect.zero)
    }
  }
}
