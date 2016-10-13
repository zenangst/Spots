import UIKit
import Keychain
import Compass
import Sugar

public struct PreLoginRouter: Routing {

  public func navigate(_ url: URL, navigationController: UINavigationController) -> Bool {
    guard let applicationDelegate = UIApplication.shared.delegate as? AppDelegate,
      let location = Compass.parse(url: url)
      else { return false }

    let arguments = location.arguments
    let route = location.path

    switch route {
    case "auth":
      // Add a small delay to remove freeze
      // http://stackoverflow.com/questions/19356488/openurl-freezes-app-for-over-10-seconds
      delay(0.1) {
        UIApplication.shared.openURL(SPTAuth.defaultInstance().loginURL)
      }
    case "callback":
      if let accessToken = arguments["access_token"] {
        let result = Keychain.setPassword(accessToken, forAccount: keychainAccount)
        print(result)

        SPTUser.requestCurrentUser(withAccessToken: accessToken) { (error, user) -> Void in

          if let error = error {
            print(error)
          }

          guard let user = user as? SPTUser else { return }

          username = user.canonicalUserName
          SPTAuth.defaultInstance().handleAuthCallback(withTriggeredAuthURL: url, callback: { (error, session) -> Void in
            applicationDelegate.session = session
            applicationDelegate.cache.add("session", object: session!)
          })
        }

        applicationDelegate.window?.rootViewController = applicationDelegate.mainController
      }
    default:
      break
    }

    return true
  }
}
