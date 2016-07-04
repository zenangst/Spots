import Malibu

struct MalibuConfigurator: Configurator {

  func configure() {
    let networking = Networking(baseURLString: "https://api.spotify.com/v1/")
    Malibu.register("api", networking: networking)
    Malibu.logger.level = .Error

    Malibu.networking("api").additionalHeaders = {
      ["Accept" : "application/json"]
    }
  }

}
