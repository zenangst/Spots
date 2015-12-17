import Compass
import Sugar

struct CompassConfigurator: Configurator {

  static func configure() {
    Compass.scheme = Application.mainScheme!
    Compass.routes = [
      "auth",
      "callback",
      "play:{uri}",
      "playlist:{uri}",
      "playlists",
      "stop"
    ]
  }
}
