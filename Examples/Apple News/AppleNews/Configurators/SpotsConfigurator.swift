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
      collectionView.backgroundColor = UIColor.whiteColor()
      layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 0)
      layout.minimumInteritemSpacing = 0
      layout.minimumLineSpacing = 0
      collectionView.contentInset.right = 10
    }

    CarouselSpot.configure = { collectionView, layout in
      collectionView.backgroundColor = UIColor.whiteColor()
      layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
      layout.minimumInteritemSpacing = 0
      layout.minimumLineSpacing = 10
    }

    ListSpot.register(header: SearchHeaderView.self, withIdentifier: "search")
    ListSpot.register(header: ListHeaderView.self, withIdentifier: "list")

    ListSpot.configure = { tableView in tableView.tableFooterView = UIView(frame: CGRect.zero) }

    ListSpot.register(view: FeedItemCell.self, withIdentifier: Cell.Feed)
    ListSpot.register(view: FeaturedFeedItemCell.self, withIdentifier: Cell.FeaturedFeed)
    ListSpot.register(view: FeedDetailItemCell.self, withIdentifier: Cell.FeedDetail)

    CarouselSpot.register(view: GridTopicCell.self, withIdentifier: Cell.Topic)
    GridSpot.register(view: GridTopicCell.self, withIdentifier: Cell.Topic)
  }
}
