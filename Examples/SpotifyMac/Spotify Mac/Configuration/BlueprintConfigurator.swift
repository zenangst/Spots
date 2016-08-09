import Spots
import Sugar
import Brick
import Tailor

struct BlueprintConfigurator: Configurator {

  func configure() {
    blueprints.register(AlbumBlueprint.self)
    blueprints.register(AlbumsBlueprint.self)
    blueprints.register(ArtistBlueprint.self)
    blueprints.register(BrowseBlueprint.self)
    blueprints.register(CategoryBlueprint.self)
    blueprints.register(FollowingBlueprint.self)
    blueprints.register(PlaylistBlueprint.self)
    blueprints.register(PlaylistsBlueprint.self)
    blueprints.register(SongsBlueprint.self)
    blueprints.register(TopArtistsBlueprint.self)
    blueprints.register(TopTracksBlueprint.self)
  }
}
