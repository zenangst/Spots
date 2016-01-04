import UIKit
import Keychain
import Compass
import Sugar

public struct PreLoginRouter: Routing {

  public func navigate(url: NSURL, navigationController: UINavigationController) -> Bool {
    guard let applicationDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
      else { return false }

    return Compass.parse(url) { route, arguments in
      switch route {
      case "auth":
        // Add a small delay to remove freeze
        // http://stackoverflow.com/questions/19356488/openurl-freezes-app-for-over-10-seconds
        delay(0.1) {
          UIApplication.sharedApplication().openURL(SPTAuth.defaultInstance().loginURL)
        }
      case "callback":
        if let accessToken = arguments["access_token"] {
          Keychain.setPassword(accessToken, forAccount: keychainAccount)

          SPTUser.requestCurrentUserWithAccessToken(accessToken) { (error, user) -> Void in

            if let error = error {
              print(error)
            }

            username = user.canonicalUserName

            SPTAuth.defaultInstance().handleAuthCallbackWithTriggeredAuthURL(url, callback: { (error, session) -> Void in
              applicationDelegate.session = session
              applicationDelegate.cache.add("session", object: session)
            })
          }

          applicationDelegate.window?.rootViewController = applicationDelegate.mainController
        }
      default:
        break
      }
    }
  }
}
