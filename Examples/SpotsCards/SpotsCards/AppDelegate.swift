import UIKit
import Spots

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var navigationController: UINavigationController?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    window = UIWindow(frame: UIScreen.mainScreen().bounds)

    SpotFactory.register("cards", spot: CardSpot.self)
    CarouselSpot.views["card"] = CardSpotCell.self

    CarouselSpot.configure = { collectionView in
      collectionView.backgroundColor = UIColor(red:0.110, green:0.110, blue:0.110, alpha: 1)
    }

    SpotsController.configure = {
      $0.backgroundColor = UIColor.whiteColor()
    }

    let controller = JSONController()

    controller.title = "Spots Cards".uppercaseString

    navigationController = UINavigationController(rootViewController: controller)
    window?.rootViewController = navigationController

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
}

