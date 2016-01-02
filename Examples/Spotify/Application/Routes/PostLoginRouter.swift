import UIKit
import Keychain
import Compass

public struct PostLoginRouter: Routing {

  public func navigate(url: NSURL, navigationController: UINavigationController) -> Bool {
    guard let applicationDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
      else { return false }

    return Compass.parse(url) { route, arguments in
      switch route {
      case "playlists":
        let controller = PlaylistController(playlistID: nil)
        controller.title = "Playlists"
        navigationController.pushViewController(controller, animated: true)
      case "playlist:{uri}":
        if let playlist = arguments["uri"] {
          let controller = PlaylistController(playlistID: playlist)
          navigationController.pushViewController(controller, animated: true)
        }
      case "play:{uri}:{track}":
        if let playlist = arguments["uri"],
          trackString = arguments["track"],
          track = Int32(trackString) {
            let realPlaylist = playlist.stringByReplacingOccurrencesOfString("-", withString: ":")

            SPTPlaylistSnapshot.playlistWithURI(NSURL(string: realPlaylist), accessToken: Keychain.password(forAccount: keychainAccount), callback: { (error, object) -> Void in
              guard let object = object as? SPTPlaylistSnapshot else { return }
              var urls = [NSURL]()

              object.firstTrackPage.items.forEach {
                urls.append($0.uri)
              }

              applicationDelegate.player.playURIs(urls,
                fromIndex: track,
                callback: { (error) -> Void in })
            })
        }
      case "stop":
        guard applicationDelegate.player.isPlaying else { return }
        applicationDelegate.player.stop({ (error) -> Void in })
      case "next":
        applicationDelegate.player.skipNext({ (error) -> Void in })
      case "previous":
        applicationDelegate.player.skipPrevious({ (error) -> Void in })
      case "openPlayer":
        applicationDelegate.mainController.playerController.openPlayer()
      default:
        break
      }
    }
  }
}
