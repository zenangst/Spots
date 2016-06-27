import Compass

struct CompassConfigurator: Configurator {

  func configure() {
    Compass.scheme = "spots"
    Compass.routes = [
      "auth",
      "callback",
      "play:{uri}:{track}",
      "song:{uri}",
      "playlist:{uri}",
      "playlists",
      "stop",
      "next",
      "previous",
      "openPlayer",
      "logout"
    ]
  }
}
