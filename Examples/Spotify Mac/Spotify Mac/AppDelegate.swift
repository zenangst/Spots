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
    GridSpot.grids["grid"] = GridSpotItem.self

    let spotsController = SpotsController([
      "components" : [
        ["kind" : "grid", "items" : [["title" : "hello", "kind" : "grid", "size" : ["height" : 88]]]],
        ["kind" : "list", "items" : [["title" : "hello", "kind" : "list", "size" : ["height" : 44]]]]
      ]
      ])

    window.contentView = spotsController.view
  }

  func applicationWillTerminate(aNotification: NSNotification) {
    // Insert code here to tear down your application
  }
}

