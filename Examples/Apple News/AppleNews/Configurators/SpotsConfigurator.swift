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
      $0.backgroundColor = UIColor.white
    }

    GridSpot.configure = { collectionView, layout in
      collectionView.backgroundColor = UIColor.white
      layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 0)
      layout.minimumInteritemSpacing = 0
      layout.minimumLineSpacing = 0
      collectionView.contentInset.right = 10
    }

    CarouselSpot.configure = { collectionView, layout in
      collectionView.backgroundColor = UIColor.white
      layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
      layout.minimumInteritemSpacing = 10
      layout.minimumLineSpacing = 10
    }

    ListSpot.register(header: SearchHeaderView.self, identifier: "search")
    ListSpot.register(header: ListHeaderView.self, identifier: "list")

    ListSpot.configure = { tableView in tableView.tableFooterView = UIView(frame: CGRect.zero) }

    ListSpot.register(view: FeedItemCell.self, identifier: Cell.Feed)
    ListSpot.register(view: FeaturedFeedItemCell.self, identifier: Cell.FeaturedFeed)
    ListSpot.register(view: FeedDetailItemCell.self, identifier: Cell.FeedDetail)

    CarouselSpot.register(view: GridTopicCell.self, identifier: Cell.Topic)
    GridSpot.register(view: GridTopicCell.self, identifier: Cell.Topic)
  }
}
