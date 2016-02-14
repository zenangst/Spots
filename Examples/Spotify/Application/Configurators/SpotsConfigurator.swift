import Spots
import Hue

struct SpotsConfigurator: Configurator {

  static func configure() {

    SpotsController.configure = { scrollView in
      scrollView.backgroundColor = UIColor.blackColor()
    }

    CarouselSpot.configure = { collectionView in
      collectionView.backgroundColor = UIColor.clearColor()
    }

    CarouselSpot.views["playlist"] = PlaylistGridSpotCell.self
    CarouselSpot.views["featured"] = FeaturedGridSpotCell.self

    GridSpot.configure = { collectionView in
      collectionView.backgroundColor = UIColor.clearColor()
    }

    GridSpot.views["player"] = PlayerGridSpotCell.self
    GridSpot.views["playlist"] = PlaylistGridSpotCell.self
    GridSpot.views["featured"] = FeaturedGridSpotCell.self

    ListSpot.configure = { tableView in
      let inset: CGFloat = 15

      tableView.backgroundColor = UIColor.clearColor()
      tableView.layoutMargins = UIEdgeInsetsZero
      tableView.tableFooterView = UIView(frame: CGRect.zero)
      tableView.separatorInset = UIEdgeInsets(top: inset,
        left: inset,
        bottom: inset,
        right: inset)
      tableView.separatorColor = UIColor.hex("FFF").alpha(0.2)
    }

    ListSpot.headers["search"] = SearchHeaderView.self
    ListSpot.headers["list"] = ListHeaderView.self

    ListSpot.views["default"] = DefaultListSpotCell.self
    ListSpot.views["playlist"] = PlaylistListSpotCell.self
    ListSpot.views["player"] = PlayerListSpotCell.self
    ListSpot.defaultView = DefaultListSpotCell.self
  }
}
