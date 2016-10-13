import Malibu

struct MalibuConfigurator: Configurator {

  func configure() {
    let networking = Networking(baseUrl: "https://api.spotify.com/v1/")
    Malibu.register("api", networking: networking)
    Malibu.logger.level = .error

    Malibu.networking("api").additionalHeaders = {
      ["Accept" : "application/json"]
    }
  }

}
