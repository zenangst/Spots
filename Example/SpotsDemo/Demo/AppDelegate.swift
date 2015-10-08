import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var navigationController: UINavigationController?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    window = UIWindow(frame: UIScreen.mainScreen().bounds)

    let bundlePath = NSBundle.mainBundle().pathForResource("components", ofType: "json")
    let data = NSFileManager.defaultManager().contentsAtPath(bundlePath!)
    let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)

    let components = Parser.parse(json as! [String : AnyObject])
    let controller = SpotsController(spots: components)
    controller.title = "Spots".uppercaseString
    controller.view.backgroundColor = .whiteColor()

    navigationController = UINavigationController(rootViewController: controller)
    window?.rootViewController = navigationController
    window?.makeKeyAndVisible()
    
    return true
  }
}

