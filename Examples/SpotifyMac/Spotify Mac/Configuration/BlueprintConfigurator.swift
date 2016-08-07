import Spots
import Sugar
import Brick
import Tailor

struct BlueprintConfigurator: Configurator {

  func configure() {
    blueprints[AlbumBlueprint.key] = AlbumBlueprint.drawing
    blueprints[AlbumsBlueprint.key] = AlbumsBlueprint.drawing
    blueprints[ArtistBlueprint.key] = ArtistBlueprint.drawing
    blueprints[BrowseBlueprint.key] = BrowseBlueprint.drawing
    blueprints[CategoryBlueprint.key] = CategoryBlueprint.drawing
    blueprints[FollowingBlueprint.key] = FollowingBlueprint.drawing
    blueprints[PlaylistBlueprint.key] = PlaylistBlueprint.drawing
    blueprints[PlaylistsBlueprint.key] = PlaylistsBlueprint.drawing
    blueprints[SongsBlueprint.key] = SongsBlueprint.drawing
    blueprints[TopArtistsBlueprint.key] = TopArtistsBlueprint.drawing
    blueprints[TopTracksBlueprint.key] = TopTracksBlueprint.drawing
  }
}
