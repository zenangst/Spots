import UIKit
import Spots
import Compass
import Sugar
import Keychain
import Cache

let keychainAccount = "spots-accessToken"
var username: String? {
  set(value) {
    NSUserDefaults.standardUserDefaults().setValue(value, forKey: "username")
    NSUserDefaults.standardUserDefaults().synchronize()
  }
  get {
    return NSUserDefaults.standardUserDefaults().valueForKey("username") as? String
  }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var navigationController: UINavigationController?
  lazy var mainController: MainController = MainController()
  lazy var cache = Cache<SPTSession>(name: "Spotify")

  let configurators: [Configurator.Type] = [
    SpotifyConfigurator.self,
    CompassConfigurator.self,
    SpotsConfigurator.self
  ]

  var session: SPTSession? {
    didSet {
      guard let session = session else { return }
      player.loginWithSession(session, callback: { (error) -> Void in
        if let error = error {
          print(error)
        }
      })
    }
  }

  lazy var player: SPTAudioStreamingController = {
    let player = SPTAudioStreamingController(clientId: SPTAuth.defaultInstance().clientID)

    return player
  }()

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    configurators.forEach { $0.configure() }

    window = UIWindow(frame: UIScreen.mainScreen().bounds)

    session = SPTSession(userName: username,
      accessToken: Keychain.password(forAccount: keychainAccount),
      expirationDate: nil)

    let controller = AuthController(spots: [ListSpot(component:
      Component(items:
        [ListItem(title: "Auth", action: "auth", kind: "playlist", size: CGSize(width: 120, height: 88))])
      )
      ])
    controller.title = "Spotify".uppercaseString
    navigationController = UINavigationController(rootViewController: controller)
    window?.rootViewController = navigationController

    cache.object("session") { (session: SPTSession?) -> Void in
      dispatch {
        if let session = session {
          self.session = session
          self.window?.rootViewController = self.mainController
        }
      }
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

            SPTUser.requestCurrentUserWithAccessToken(accessToken, callback: { (error, user) -> Void in

              if let error = error {
                print(error)
              }

              username = user.canonicalUserName

              SPTAuth.defaultInstance().handleAuthCallbackWithTriggeredAuthURL(url, callback: { (error, session) -> Void in
                self.session = session
                self.cache.add("session", object: session)
              })
            })

            self.window?.rootViewController = self.mainController
          }
        case "playlists":
          let controller = PlaylistController(playlistID: nil)
          controller.title = "Playlists"
          self.mainController.pushViewController(controller, animated: true)
        case "playlist:{uri}":
          if let playlist = arguments["uri"] {
            let controller = PlaylistController(playlistID: playlist)
            self.mainController.pushViewController(controller, animated: true)
          }
        case "play:{uri}:{track}":
          if let playlist = arguments["uri"],
            trackString = arguments["track"],
            track = Int32(trackString) {
              let realPlaylist = playlist.stringByReplacingOccurrencesOfString("-", withString: ":")

              SPTPlaylistSnapshot.playlistWithURI(NSURL(string: realPlaylist), accessToken: Keychain.password(forAccount: keychainAccount), callback: { (error, object) -> Void in
                guard let object = object as? SPTPlaylistSnapshot else { return }
                var trackObject: SPTPartialTrack!
                var urls = [NSURL]()

                object.firstTrackPage.items.enumerate().forEach {
                  if Int32($0.0) == track {
                    trackObject = $0.1 as! SPTPartialTrack
                  }
                  urls.append($0.1.uri)
                }

                self.player.playURIs(urls,
                  fromIndex: track,
                  callback: { (error) -> Void in })

                NSNotificationCenter.defaultCenter().postNotificationName("updatePlayer",
                  object: nil,
                  userInfo: [
                    "title" : trackObject.name,
                    "image" : trackObject.album.largestCover.imageURL.absoluteString ?? "",
                    "artist" :trackObject.artists.first?.name ?? "",
                    "track" : trackObject.name
                  ])
              })
          }
        case "stop":
          guard self.player.isPlaying else { return }
          self.player.stop({ (error) -> Void in })
        case "next":
          self.player.skipNext({ (error) -> Void in })
        case "previous":
          self.player.skipPrevious({ (error) -> Void in })
        default:
          print("\(route) is not registered")
        }
      }
  }
}

