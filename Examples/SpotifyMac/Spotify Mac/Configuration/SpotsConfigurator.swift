import Spots

struct SpotsConfigurator: Configurator {

  func configure() {
    CarouselSpot.register(view: ArtistGridItem.self, identifier: "artist")
    CarouselSpot.register(view: AlbumGridItem.self, identifier: "album")
    CarouselSpot.register(view: GridSpotItem.self, identifier: "carousel")
    CarouselSpot.register(view: CategoryGridItem.self, identifier: "category")
    CarouselSpot.register(view: FeaturedGridItem.self, identifier: "featured")
    CarouselSpot.register(view: GridListItem.self, identifier: "list")

    GridSpot.register(view: ArtistGridItem.self, identifier: "artist")
    GridSpot.register(view: AlbumGridItem.self, identifier: "album")
    GridSpot.register(view: CategoryGridItem.self, identifier: "category")
    GridSpot.register(view: FeaturedGridItem.self, identifier: "featured")
    GridSpot.register(view: GridSpotItem.self, identifier: "grid")
    GridSpot.register(view: GridListItem.self, identifier: "list")

    ListSpot.register(view: HeaderGridItem.self, identifier: "header")
    ListSpot.register(view: TableRow.self, identifier: "list")
    ListSpot.register(view: TrackRow.self, identifier: "track")
    ListSpot.register(view: HeroGridItem.self, identifier: "hero")
    ListSpot.register(defaultView: TableRow.self)

    CarouselSpot.Default.sectionInsetTop = 0.0
    CarouselSpot.Default.sectionInsetLeft = 10.0
    CarouselSpot.Default.sectionInsetBottom = 0.0
    CarouselSpot.Default.sectionInsetRight = 30.0
    CarouselSpot.Default.minimumInteritemSpacing = 10.0
    CarouselSpot.Default.minimumLineSpacing = 10.0
    CarouselSpot.Default.titleLeftInset = 10.0

    GridSpot.Default.sectionInsetTop = 0.0
    GridSpot.Default.sectionInsetLeft = 16.0
    GridSpot.Default.sectionInsetBottom = 5.0
    GridSpot.Default.sectionInsetRight = 0.0
    GridSpot.Default.titleLeftInset = 16.0
    GridSpot.Default.Flow.minimumInteritemSpacing = 10.0
    GridSpot.Default.Flow.minimumLineSpacing = 10.0

    ListSpot.Default.contentInsetsTop = 0.0
    ListSpot.Default.contentInsetsLeft = 16.0
    ListSpot.Default.contentInsetsRight = 20.0
    ListSpot.Default.contentInsetsBottom = 0.0
    ListSpot.Default.titleLeftInset = 16.0
    ListSpot.Default.titleTopInset = 0.0
  }
}
