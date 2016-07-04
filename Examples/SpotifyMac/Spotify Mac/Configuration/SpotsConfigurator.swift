import Spots

struct SpotsConfigurator: Configurator {

  func configure() {
    CarouselSpot.grids["artist"] = ArtistGridItem.self
    CarouselSpot.grids["album"] = AlbumGridItem.self
    CarouselSpot.grids["carousel"] = GridSpotItem.self
    CarouselSpot.grids["category"] = CategoryGridItem.self
    CarouselSpot.grids["featured"] = FeaturedGridItem.self
    CarouselSpot.grids["hero"] = HeroGridItem.self
    CarouselSpot.grids["list"] = GridListItem.self
    GridSpot.grids["artist"] = ArtistGridItem.self
    GridSpot.grids["album"] = AlbumGridItem.self
    GridSpot.grids["category"] = CategoryGridItem.self
    GridSpot.grids["featured"] = FeaturedGridItem.self
    GridSpot.grids["grid"] = GridSpotItem.self
    GridSpot.grids["header"] = HeaderGridItem.self
    GridSpot.grids["list"] = GridListItem.self
    ListSpot.views["list"] = TableRow.self
    ListSpot.views["track"] = TrackRow.self

    CarouselSpot.Default.sectionInsetTop = 30.0
    CarouselSpot.Default.sectionInsetLeft = 30.0
    CarouselSpot.Default.sectionInsetBottom = 30.0
    CarouselSpot.Default.sectionInsetRight = 30.0
    CarouselSpot.Default.minimumInteritemSpacing = 10.0
    CarouselSpot.Default.minimumLineSpacing = 10.0

    GridSpot.Default.sectionInsetTop = 30.0
    GridSpot.Default.sectionInsetLeft = 30.0
    GridSpot.Default.sectionInsetBottom = 0.0
    GridSpot.Default.sectionInsetRight = 30.0
    GridSpot.Default.Flow.minimumInteritemSpacing = 10.0
    GridSpot.Default.Flow.minimumLineSpacing = 10.0

    ListSpot.Default.contentInsetsTop = 30.0
    ListSpot.Default.contentInsetsLeft = 30.0
    ListSpot.Default.titleLeftInset = 8.0
    ListSpot.Default.titleTopInset = 8.0
  }
}
