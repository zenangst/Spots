import Cocoa
import Spots
import Brick
import Cocoa
import Sugar

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  @IBOutlet weak var window: NSWindow!

  func applicationDidFinishLaunching(aNotification: NSNotification) {

    ListSpot.views["list"] = ListSpotItem.self
    GridSpot.grids["grid"] = GridSpotItem.self
    CarouselSpot.grids["carousel"] = GridSpotItem.self

    let items: [[String : AnyObject]] = [
      ["title" : "foo", "subtitle" : "bar", "kind" : "list", "size" : ["height" : 44]],
      ["title" : "foo", "subtitle" : "bar", "kind" : "list", "size" : ["height" : 44]],
      ["title" : "foo", "kind" : "list", "size" : ["height" : 44]]
    ]

    let spotsController = SpotsController([
      "components" : [
        ["kind" : "grid", "size" : ["height" : 88], "span" : 3, "items" : [
          ["title" : "foo", "size": ["height" : 88]],
          ["title" : "ar", "size": ["height" : 88]],
          ["title" : "baz", "size": ["height" : 88]]
          ]
        ],
        ["kind" : "list", "items" : items]
      ]
      ])

    window.contentView = spotsController.view
    window.becomeKeyWindow()
  }

  func applicationWillTerminate(aNotification: NSNotification) {
    // Insert code here to tear down your application
  }
}
