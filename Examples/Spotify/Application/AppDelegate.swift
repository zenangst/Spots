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
  lazy var cache = Cache<SPTSession>(name: "Spotify")
  lazy var mainController: MainController = MainController()

  lazy var authController: UINavigationController = {
    let controller = AuthController(spots: [ListSpot(component:
      Component(items:
        [ListItem(title: "Auth", action: "auth", kind: "playlist", size: CGSize(width: 120, height: 88))])
      )
      ])
    let navigationController = UINavigationController(rootViewController: controller)

    controller.title = "Spotify".uppercaseString

    return navigationController
  }()

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
    player.playbackDelegate = self

    return player
  }()

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    configurators.forEach { $0.configure() }
    window = UIWindow(frame: UIScreen.mainScreen().bounds)

    window?.rootViewController = authController

    cache.object("session") { (session: SPTSession?) -> Void in
      dispatch {
        guard let session = session else { return }
        self.session = session
        self.window?.rootViewController = self.mainController
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
      if session == nil {
        return PreLoginRouter().navigate(url, navigationController: authController)
      }

      guard let navigationController = mainController.selectedViewController as? UINavigationController
        else { return false }

      return PostLoginRouter().navigate(url, navigationController: navigationController)
  }
}

extension AppDelegate: SPTAudioStreamingPlaybackDelegate {

  func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangeToTrack trackMetadata: [NSObject : AnyObject]!) {

    guard let name = trackMetadata["SPTAudioStreamingMetadataArtistName"] as? String,
    artist = trackMetadata["SPTAudioStreamingMetadataArtistName"] as? String,
    track = trackMetadata["SPTAudioStreamingMetadataTrackName"] as? String,
    uri = trackMetadata["SPTAudioStreamingMetadataAlbumURI"] as? String
      else { return }

    SPTAlbum.albumWithURI(NSURL(string: uri), accessToken: Keychain.password(forAccount: keychainAccount), market: nil) { (error, object) -> Void in
      guard let album = object as? SPTPartialAlbum else { return }

      NSNotificationCenter.defaultCenter().postNotificationName("updatePlayer",
        object: nil,
        userInfo: [
          "title" : name,
          "image" : album.largestCover.imageURL.absoluteString,
          "artist" :artist,
          "track" : track
        ])
    }
  }
}
