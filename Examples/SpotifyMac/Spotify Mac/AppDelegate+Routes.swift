import Compass

extension AppDelegate {

  func registerURLScheme() {
    NSAppleEventManager.sharedAppleEventManager().setEventHandler(self,
                                                                  andSelector: #selector(handle(_:replyEvent:)),
                                                                  forEventClass: AEEventClass(kInternetEventClass),
                                                                  andEventID: AEEventID(kAEGetURL))

    if let bundleIdentifier = NSBundle.mainBundle().bundleIdentifier {
      LSSetDefaultHandlerForURLScheme("spots", bundleIdentifier as CFString)
    }
  }

  func handle(event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor) {
    if let stringURL = event.paramDescriptorForKeyword(AEKeyword(keyDirectObject))?.stringValue,
      url = NSURL(string: stringURL) {

      if stringURL.hasPrefix("spots://callback") {
        spotsSession.auth(url)
        return
      }

      Compass.parse(url) { route, arguments, fragments in
        switch route {
        case "browse":
          self.splitView.detailView = self.browseController.view
        case "playlist:{user_id}:{playlist_id}":
          guard let userID = arguments["user_id"],
            playlistID = arguments["playlist_id"] else { return }
          let playlistController = PlaylistController(cacheKey: "playlist:\(userID):\(playlistID)")
          playlistController.request = PlaylistRequest(userID: userID, playlistID: playlistID)
          self.currentController = playlistController
          self.splitView.detailView = playlistController.view
          break
        default: break
        }
      }
    }
  }
}
