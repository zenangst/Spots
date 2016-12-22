import UIKit
import Spots

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    CarouselSpot.register(view: FeaturedCell.self, identifier: "featured")
    CarouselSpot.register(view: GridCell.self, identifier: "default")

    GridSpot.register(view: FeaturedCell.self, identifier: "featured")
    GridSpot.register(view: GridCell.self, identifier: "default")
    GridSpot.register(defaultView: GridCell.self)

    ListSpot.register(header: CompositionListHeader.self, identifier: "header")
    ListSpot.register(view: CompositionListView.self, identifier: "view")
    ListSpot.register(view: ListCell.self, identifier: "default")
    ListSpot.register(defaultView: ListCell.self)

    let controller = CompositionController()
    controller.reloadIfNeeded(CompositionController.components)

    #if os(iOS)
      GridSpot.configure = { collectionView, _ in
        collectionView.backgroundColor = UIColor.white
      }

      CarouselSpot.configure = { collectionView, _ in
        collectionView.backgroundColor = UIColor.white
      }

      Spots.Controller.configure = { scrollView in
        scrollView.backgroundColor = UIColor.white
      }
    #endif

    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = controller
    window?.makeKeyAndVisible()

    return true
  }
}
