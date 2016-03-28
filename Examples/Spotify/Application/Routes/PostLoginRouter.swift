import UIKit
import Keychain
import Compass
import Cache
import Sugar

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
        controller.refreshData()
        navigationController.pushViewController(controller, animated: true)
      case "song:{uri}":
        guard let uri = arguments["uri"] else { return }

        player.playURIs([NSURL(string: uri.replace("_", with: ":"))!], fromIndex: 0, callback: { (error) -> Void in })
      case "play:{uri}:{track}":
        guard let trackString = arguments["track"],
          index = Int(trackString) else { return }

        let urls = applicationDelegate.mainController.playerController.currentURIs
        let url = urls[index]
        let startIndex = index > 0 ? index - 1 : 0
        let modifiedList = urls[urls.startIndex + startIndex..<urls.endIndex].map { $0 }

        if let newIndex = modifiedList.indexOf({ $0 == url }) {
          player.playURIs(modifiedList,
            fromIndex: Int32(newIndex),
            callback: { (error) -> Void in })
        }
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
