import Spots

struct SpotsConfigurator: Configurator {

  func configure() {
    CarouselSpot.register(item: ArtistGridItem.self, identifier: "artist")
    CarouselSpot.register(item: AlbumGridItem.self, identifier: "album")
    CarouselSpot.register(item: GridSpotItem.self, identifier: "carousel")
    CarouselSpot.register(item: CategoryGridItem.self, identifier: "category")
    CarouselSpot.register(item: FeaturedGridItem.self, identifier: "featured")
    CarouselSpot.register(item: GridListItem.self, identifier: "list")

    GridSpot.register(item: ArtistGridItem.self, identifier: "artist")
    GridSpot.register(item: AlbumGridItem.self, identifier: "album")
    GridSpot.register(item: CategoryGridItem.self, identifier: "category")
    GridSpot.register(item: FeaturedGridItem.self, identifier: "featured")
    GridSpot.register(item: GridSpotItem.self, identifier: "grid")
    GridSpot.register(item: GridListItem.self, identifier: "list")

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
