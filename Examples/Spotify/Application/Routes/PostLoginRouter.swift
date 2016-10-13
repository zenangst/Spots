import UIKit
import Keychain
import Compass
import Cache
import Sugar

public struct PostLoginRouter: Routing {

  public func navigate(_ url: URL, navigationController: UINavigationController) -> Bool {
    guard let applicationDelegate = UIApplication.shared.delegate as? AppDelegate,
    let location = Compass.parse(url: url)
      else { return false }

    let route = location.path
    let arguments = location.arguments

//    return Compass.parse(url) { route, arguments in

      let player = applicationDelegate.mainController.playerController.player

    switch route {
    case "playlists":
      let controller = PlaylistController(playlistID: nil)
      controller.title = "Playlists"
      navigationController.pushViewController(controller, animated: true)
    case "playlist:{uri}":
      guard let playlist = arguments["uri"] else { return false }
      let controller = PlaylistController(playlistID: playlist)
      controller.refreshData()
      navigationController.pushViewController(controller, animated: true)
    case "song:{uri}":
      guard let uri = arguments["uri"] else { return false }

      player.playURIs([NSURL(string: uri.replace("_", with: ":"))!], from: 0, callback: { (error) -> Void in })
    case "play:{uri}:{track}":
      guard let trackString = arguments["track"],
        let index = Int(trackString) else { return false }

      let urls = applicationDelegate.mainController.playerController.currentURIs
      let url = urls[index]
      let startIndex = index > 0 ? index - 1 : 0
      let modifiedList = urls[urls.startIndex + startIndex..<urls.endIndex].map { $0 }

      if let newIndex = modifiedList.index(where: { $0 == url }) {
        player.playURIs(modifiedList,
                        from: Int32(newIndex),
                        callback: { (error) -> Void in })
      }
    case "stop":
      guard player.isPlaying else { return false }
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

    return true
  }
}
