import Spots

struct SpotsConfigurator {
  func configure() {
    SpotsController.configure = {
      $0.backgroundColor = UIColor.whiteColor()
    }

    ListSpot.headers["search"] = SearchHeaderView.self
    ListSpot.headers["list"] = ListHeaderView.self
    ListSpot.configure = { tableView in tableView.tableFooterView = UIView(frame: CGRect.zero) }
    ListSpot.views["feed"] = FeedItemCell.self
    ListSpot.views["featured-feed"] = FeaturedFeedItemCell.self
    ListSpot.views["feed-detail"] = FeedDetailItemCell.self

    CarouselSpot.views["topic"] = GridTopicCell.self
    GridSpot.views["topic"] = GridTopicCell.self
  }
}
