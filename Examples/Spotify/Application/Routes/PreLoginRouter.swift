import UIKit
import Keychain
import Compass

public struct PreLoginRouter: Routing {

  public func navigate(url: NSURL, navigationController: UINavigationController) -> Bool {
    guard let applicationDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
      else { return false }

    return Compass.parse(url) { route, arguments in
      switch route {
      case "auth":
        UIApplication.sharedApplication().openURL(SPTAuth.defaultInstance().loginURL)
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
