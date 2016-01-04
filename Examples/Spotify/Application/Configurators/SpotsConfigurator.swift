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

    GridSpot.cells["player"] = PlayerGridSpotCell.self
    GridSpot.cells["playlist"] = PlaylistGridSpotCell.self
    GridSpot.cells["featured"] = FeaturedGridSpotCell.self

    ListSpot.configure = { tableView in
      let inset: CGFloat = 15

      tableView.backgroundColor = UIColor.blackColor()
      tableView.layoutMargins = UIEdgeInsetsZero
      tableView.tableFooterView = UIView(frame: CGRect.zero)
      tableView.separatorInset = UIEdgeInsets(top: inset,
        left: inset,
        bottom: inset,
        right: inset)
      tableView.separatorColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.2)
    }

    ListSpot.headers["list"] = ListHeaderView.self
    ListSpot.cells["default"] = DefaultListSpotCell.self
    ListSpot.cells["playlist"] = PlaylistListSpotCell.self
    ListSpot.defaultCell = DefaultListSpotCell.self
  }
}
