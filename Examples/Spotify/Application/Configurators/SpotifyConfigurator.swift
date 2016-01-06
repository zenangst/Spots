struct SpotifyConfigurator: Configurator {

  static func configure() {
    SPTAuth.defaultInstance().clientID = "a73161d177934f639fe3b3506d5a1005"
    SPTAuth.defaultInstance().redirectURL = NSURL(string: "spots://callback")
    SPTAuth.defaultInstance().requestedScopes = [SPTAuthPlaylistModifyPrivateScope, SPTAuthPlaylistReadPrivateScope, SPTAuthStreamingScope]
  }
}
