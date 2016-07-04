import Compass

struct CompassConfigurator: Configurator {

  func configure() {
    Compass.scheme = "spots"
    Compass.routes = [
      "auth",
      "artist:{artist_id}",
      "browse",
      "album:{album_id}",
      "albums",
      "callback",
      "category:{category_id}",
      "logout",
      "next",
      "following",
      "preview",
      "topArtists",
      "topTracks",
      "openPlayer",
      "play:{uri}:{track}",
      "playlist:{user_id}:{playlist_id}",
      "playlists",
      "previous",
      "song:{uri}",
      "songs",
      "stop",
    ]
  }
}
