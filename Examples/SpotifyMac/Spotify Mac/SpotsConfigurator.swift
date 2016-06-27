import Spots

struct SpotsConfigurator: Configurator {

  func configure() {
    ListSpot.views["list"] = TableViewCell.self
    GridSpot.grids["list"] = GridListItem.self
    GridSpot.grids["grid"] = GridSpotItem.self
    GridSpot.grids["featured"] = FeaturedGridItem.self
    CarouselSpot.grids["carousel"] = GridSpotItem.self
    CarouselSpot.grids["featured"] = FeaturedGridItem.self
    CarouselSpot.grids["list"] = GridListItem.self
    CarouselSpot.grids["hero"] = HeroGridItem.self
  }
}
