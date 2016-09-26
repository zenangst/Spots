import Spots
import Hue

struct SpotsConfigurator: Configurator {

  static func configure() {

    SpotsController.configure = { scrollView in
      scrollView.backgroundColor = UIColor.blackColor()
    }

    CarouselSpot.configure = { collectionView, layout in
      collectionView.backgroundColor = UIColor.clearColor()

      layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
      layout.minimumInteritemSpacing = 0
      layout.minimumLineSpacing = 5
    }

    CarouselSpot.register(view: PlaylistGridSpotCell.self, identifier: "playlist")
    CarouselSpot.register(view: FeaturedGridSpotCell.self, identifier: "featured")

    GridSpot.configure = { collectionView, layout in
      collectionView.backgroundColor = UIColor.clearColor()

      layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 5, right: 5)
      layout.minimumInteritemSpacing = 0
      layout.minimumLineSpacing = 0
    }

    GridSpot.register(view: PlayerGridSpotCell.self, identifier: "player")
    GridSpot.register(view: PlaylistGridSpotCell.self, identifier: "playlist")
    GridSpot.register(view: FeaturedGridSpotCell.self, identifier: "featured")

    ListSpot.configure = { tableView in
      let inset: CGFloat = 15

      tableView.backgroundColor = UIColor.clearColor()
      tableView.layoutMargins = UIEdgeInsetsZero
      tableView.tableFooterView = UIView(frame: CGRect.zero)
      tableView.separatorInset = UIEdgeInsets(top: inset,
        left: inset,
        bottom: inset,
        right: inset)
      tableView.separatorColor = UIColor(hex:"FFF").alpha(0.2)
    }

    ListSpot.register(header: SearchHeaderView.self, identifier: "search")
    ListSpot.register(header: ListHeaderView.self, identifier: "list")
    ListSpot.register(defaultHeader: ListHeaderView.self)

    ListSpot.register(view: PlaylistListSpotCell.self, identifier: "playlist")
    ListSpot.register(view: PlayerListSpotCell.self, identifier: "player")
    ListSpot.register(view: DefaultListSpotCell.self, identifier: "default")
    ListSpot.register(defaultView: DefaultListSpotCell.self)

  }
}
