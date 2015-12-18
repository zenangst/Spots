import UIKit
import Keychain
import Compass

public struct PostLoginRouter: Routing {

  public func navigate(url: NSURL, navigationController: UINavigationController) -> Bool {
    guard let applicationDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
      else { return false }

    return Compass.parse(url) { route, arguments in
      switch route {
      case "playlist:{uri}":
        if let playlist = arguments["uri"] {
          let controller = PlaylistController(playlistID: playlist)
          navigationController.pushViewController(controller, animated: true)
        }
      case "play:{uri}":
        if let track = arguments["uri"] {
          let realTrack = track.stringByReplacingOccurrencesOfString("-", withString: ":")

          applicationDelegate.player.playURIs([NSURL(string: realTrack)!],
            fromIndex: 0,
            callback: { (error) -> Void in })
        }
      case "stop":
        if applicationDelegate.player.isPlaying {
          applicationDelegate.player.stop({ (error) -> Void in })
        }
      default:
        break
      }
    }
  }
}
