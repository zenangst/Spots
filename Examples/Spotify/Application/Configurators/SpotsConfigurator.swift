import Spots

struct SpotsConfigurator: Configurator {

  static func configure() {
    ListSpot.configure = { tableView in
      tableView.backgroundColor = UIColor.blackColor()
      tableView.separatorInset = UIEdgeInsets(
        top: 0, left: 7.5,
        bottom: 0, right: 7.5)
      tableView.layoutMargins = UIEdgeInsetsZero
      tableView.separatorColor = UIColor.darkGrayColor()
      tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    GridSpot.configure = { collectionView in
      collectionView.backgroundColor = UIColor.blackColor()
    }

    ListSpot.headers["list"] = ListHeaderView.self
    ListSpot.cells["default"] = DefaultListSpotCell.self
    ListSpot.cells["playlist"] = PlaylistListSpotCell.self
    ListSpot.defaultCell = DefaultListSpotCell.self

    GridSpot.cells["playlist"] = PlaylistGridSpotCell.self
  }
}
