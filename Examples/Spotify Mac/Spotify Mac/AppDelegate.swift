import Cocoa
import Spots
import Brick
import Cocoa
import Sugar

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  @IBOutlet weak var window: NSWindow!

  func applicationDidFinishLaunching(aNotification: NSNotification) {

    ListSpot.views["list"] = TableViewCell.self

    let listSpot = ListSpot(component: Component(title: "test", items: [
      ViewModel(title: "Foo", size: CGSize(width: 88, height: 44)),
      ViewModel(title: "Foo2", size: CGSize(width: 88, height: 44))
      ]))
    let listSpot2 = ListSpot(component: Component(title: "test", items: [
      ViewModel(title: "Bar", size: CGSize(width: 88, height: 44)),
      ViewModel(title: "Bar2", size: CGSize(width: 88, height: 44))
      ]))
    let listSpot3 = ListSpot(component: Component(title: "test", items: [
      ViewModel(title: "Baz", size: CGSize(width: 88, height: 44)),
      ViewModel(title: "Baz2", size: CGSize(width: 88, height: 44))
      ]))
    let spotsController = SpotsController(spots: [listSpot, listSpot2, listSpot3])

    window.contentView = spotsController.view
  }

  func applicationWillTerminate(aNotification: NSNotification) {
    // Insert code here to tear down your application
  }
}

