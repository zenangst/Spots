import Spots
import Brick

enum Header: String, StringConvertible {
  case Search, List

  var string: String {
    return rawValue
  }
}

enum Cell: String, StringConvertible {
  case Feed, FeaturedFeed, FeedDetail, Topic

  var string: String {
    return rawValue
  }
}

struct SpotsConfigurator {
  func configure() {
    SpotsController.configure = {
      $0.backgroundColor = UIColor.whiteColor()
    }

    GridSpot.configure = { collectionView, layout in
      layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 20, right: 10)
      layout.minimumInteritemSpacing = -5
      layout.minimumLineSpacing = 10
    }

    ListSpot.headers["search"] = SearchHeaderView.self
    ListSpot.headers["list"] = ListHeaderView.self

    ListSpot.configure = { tableView in tableView.tableFooterView = UIView(frame: CGRect.zero) }

    ListSpot.views[Cell.Feed] = FeedItemCell.self
    ListSpot.views[Cell.FeaturedFeed] = FeaturedFeedItemCell.self
    ListSpot.views[Cell.FeedDetail] = FeedDetailItemCell.self

    CarouselSpot.views[Cell.Topic] = GridTopicCell.self
    GridSpot.views[Cell.Topic] = GridTopicCell.self
  }
}
