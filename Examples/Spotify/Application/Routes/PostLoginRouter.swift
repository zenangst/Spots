import UIKit
import Keychain
import Compass
import Cache

public struct PostLoginRouter: Routing {

  public func navigate(url: NSURL, navigationController: UINavigationController) -> Bool {
    guard let applicationDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
      else { return false }

    return Compass.parse(url) { route, arguments in

      let player = applicationDelegate.mainController.playerController.player

      switch route {
      case "playlists":
        let controller = PlaylistController(playlistID: nil)
        controller.title = "Playlists"
        navigationController.pushViewController(controller, animated: true)
      case "playlist:{uri}":
        guard let playlist = arguments["uri"] else { return }
        let controller = PlaylistController(playlistID: playlist)
        navigationController.pushViewController(controller, animated: true)
      case "song:{uri}":
        guard let uri = arguments["uri"] else { return }

        player.playURIs([NSURL(string: uri.replace("_", with: ":"))!], fromIndex: 0, callback: { (error) -> Void in })
      case "play:{uri}:{track}":
        guard let playlist = arguments["uri"],
          trackString = arguments["track"],
          track = Int32(trackString) else { return }
        let realPlaylist = playlist.stringByReplacingOccurrencesOfString("-", withString: ":")

        SPTPlaylistSnapshot.playlistWithURI(NSURL(string: realPlaylist), accessToken: Keychain.password(forAccount: keychainAccount), callback: { (error, object) -> Void in
          guard let object = object as? SPTPlaylistSnapshot else { return }
          var urls = [NSURL]()

          object.firstTrackPage.items.forEach {
            urls.append($0.uri)
          }

          player.playURIs(urls,
            fromIndex: track,
            callback: { (error) -> Void in })
        })
      case "stop":
        guard player.isPlaying else { return }
        player.stop({ (error) -> Void in })
      case "openPlayer":
        applicationDelegate.mainController.playerController.openPlayer()
      case "logout":
        username = nil
        applicationDelegate.session = nil
        applicationDelegate.cache.remove("session")
        applicationDelegate.window?.rootViewController = applicationDelegate.authController
        Keychain.deletePassword(forAccount: keychainAccount)
      default: break
      }
    }
  }
}
