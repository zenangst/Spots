import UIKit
import Spots
import Compass
import Sugar
import Keychain
import Cache

let keychainAccount = "spots-accessToken"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var navigationController: UINavigationController?

  lazy var mainController: MainController = {
    let controller = MainController()
    return controller
  }()

  lazy var cache: Cache<SPTSession> = {
    let cache = Cache<SPTSession>(name: "Spotify")
    return cache
  }()

  var session: SPTSession? {
    didSet {
      if let session = session {
        player.loginWithSession(session, callback: { (error) -> Void in
          if let error = error {
            print(error)
          }
        })
      }
    }
  }

  lazy var player: SPTAudioStreamingController = {
    let player = SPTAudioStreamingController(clientId: SPTAuth.defaultInstance().clientID)

    return player
  }()

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    ListSpot.configure = { tableView in
      tableView.backgroundColor = UIColor.blackColor()
      tableView.separatorInset = UIEdgeInsets(
        top: 0, left: 7.5,
        bottom: 0, right: 7.5)
      tableView.layoutMargins = UIEdgeInsetsZero
      tableView.separatorColor = UIColor.darkGrayColor()
      tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    ListSpot.cells["playlist"] = PlaylistSpotCell.self

    Compass.scheme = Application.mainScheme!
    Compass.routes = ["auth", "callback", "playlist:{uri}", "play:{uri}", "stop"]

    SPTAuth.defaultInstance().clientID = NSProcessInfo.processInfo().environment["spotifyClientID"]
    SPTAuth.defaultInstance().redirectURL = NSURL(string: "spots://callback")
    SPTAuth.defaultInstance().requestedScopes = [SPTAuthPlaylistModifyPrivateScope, SPTAuthPlaylistReadPrivateScope, SPTAuthStreamingScope]

    window = UIWindow(frame: UIScreen.mainScreen().bounds)

    session = SPTSession(userName: NSProcessInfo.processInfo().environment["spotifyUsername"],
      accessToken: Keychain.password(forAccount: keychainAccount),
      expirationDate: nil)

//    cache.object("session") { (session: SPTSession?) -> Void in
//      if let session = session {
//        print("yeap")
//      }
//    }

    print(session?.isValid())

    if Keychain.password(forAccount: keychainAccount).isEmpty {
      let controller = AuthController(spots: [ListSpot(component:
        Component(items:
          [ListItem(title: "Auth", action: "auth", kind: "playlist", size: CGSize(width: 120, height: 88))])
        )
        ])
      controller.title = "Spotify".uppercaseString
      controller.spotsDelegate = controller
      navigationController = UINavigationController(rootViewController: controller)
      window?.rootViewController = navigationController
    } else {
      window?.rootViewController = mainController
    }

    applyStyles()

    window?.makeKeyAndVisible()

    return true
  }

  func applyStyles() {
    UIApplication.sharedApplication().statusBarStyle = .LightContent

    let navigationBar = UINavigationBar.appearance()
    navigationBar.barTintColor = UIColor(red:0.000, green:0.000, blue:0.000, alpha: 1)
    navigationBar.tintColor = UIColor(red:1.000, green:1.000, blue:1.000, alpha: 1)
    navigationBar.shadowImage = UIImage()
    navigationBar.titleTextAttributes = [
      NSForegroundColorAttributeName: UIColor(red:1.000, green:1.000, blue:1.000, alpha: 1)
    ]
  }

  func application(app: UIApplication,
    openURL url: NSURL,
    options: [String : AnyObject]) -> Bool {

      return Compass.parse(url) { route, arguments in
        switch route {
        case "auth":
          UIApplication.sharedApplication().openURL(SPTAuth.defaultInstance().loginURL)
        case "callback":
          if let accessToken = arguments["access_token"] {
            Keychain.setPassword(accessToken, forAccount: keychainAccount)

            SPTAuth.defaultInstance().handleAuthCallbackWithTriggeredAuthURL(url, callback: { (error, session) -> Void in
              self.session = session
              self.cache.add("session", object: session)
            })

            self.window?.rootViewController = self.mainController
          }
        case "playlist:{uri}":
          if let playlist = arguments["uri"] {
            let controller = PlaylistController(playlistID: playlist)
            self.mainController.pushViewController(controller, animated: true)
          }
        case "play:{uri}":
          if let track = arguments["uri"] {
            let realTrack = track.stringByReplacingOccurrencesOfString("-", withString: ":")

            self.player.playURIs([NSURL(string: realTrack)!],
              fromIndex: 0,
              callback: { (error) -> Void in })
          }
          break
        case "stop":
          if self.player.isPlaying {
            self.player.stop({ (error) -> Void in })
          }
          break
        default: break
        }
      }
  }
}

