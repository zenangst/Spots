import Spots

struct SpotsConfigurator: Configurator {

  static func configure() {
    CarouselSpot.configure = { collectionView in
      collectionView.backgroundColor = UIColor.blackColor()
    }

    CarouselSpot.cells["playlist"] = PlaylistGridSpotCell.self
    CarouselSpot.cells["featured"] = FeaturedGridSpotCell.self

    GridSpot.configure = { collectionView in
      collectionView.backgroundColor = UIColor.blackColor()
    }

    GridSpot.cells["playlist"] = PlaylistGridSpotCell.self
    GridSpot.cells["featured"] = FeaturedGridSpotCell.self

    ListSpot.configure = { tableView in
      tableView.backgroundColor = UIColor.blackColor()
      tableView.separatorInset = UIEdgeInsets(
        top: 0, left: 7.5,
        bottom: 0, right: 7.5)
      tableView.layoutMargins = UIEdgeInsetsZero
      tableView.separatorColor = UIColor.darkGrayColor()
      tableView.tableFooterView = UIView(frame: CGRect.zero)
    }



    ListSpot.headers["list"] = ListHeaderView.self
    ListSpot.cells["default"] = DefaultListSpotCell.self
    ListSpot.cells["playlist"] = PlaylistListSpotCell.self
    ListSpot.defaultCell = DefaultListSpotCell.self
  }
}
