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

    CarouselSpot.register(view: PlaylistGridSpotCell.self, withIdentifier: "playlist")
    CarouselSpot.register(view: FeaturedGridSpotCell.self, withIdentifier: "featured")

    GridSpot.configure = { collectionView, layout in
      collectionView.backgroundColor = UIColor.clearColor()

      layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 5, right: 5)
      layout.minimumInteritemSpacing = 0
      layout.minimumLineSpacing = 0
    }

    GridSpot.register(view: PlayerGridSpotCell.self, withIdentifier: "player")
    GridSpot.register(view: PlaylistGridSpotCell.self, withIdentifier: "playlist")
    GridSpot.register(view: FeaturedGridSpotCell.self, withIdentifier: "featured")

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
    
    ListSpot.register(header: SearchHeaderView.self, withIdentifier: "search")
    ListSpot.register(header: ListHeaderView.self, withIdentifier: "list")
    ListSpot.register(defaultHeader: ListHeaderView.self)

    ListSpot.register(view: PlaylistListSpotCell.self, withIdentifier: "playlist")
    ListSpot.register(view: PlayerListSpotCell.self, withIdentifier: "player")
    ListSpot.register(view: DefaultListSpotCell.self, withIdentifier: "default")
    ListSpot.register(defaultView: DefaultListSpotCell.self)
    
  }
}
