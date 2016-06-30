import Compass

struct CompassConfigurator: Configurator {

  func configure() {
    Compass.scheme = "spots"
    Compass.routes = [
      "auth",
      "callback",
      "browse",
      "play:{uri}:{track}",
      "song:{uri}",
      "playlist:{user_id}:{playlist_id}",
      "playlists",
      "stop",
      "next",
      "previous",
      "openPlayer",
      "logout"
    ]
  }
}
