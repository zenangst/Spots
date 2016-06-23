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

    let leftViewItems: [[String : AnyObject]] = [
      ["title" : "Browse", "subtitle" : "", "kind" : "list", "size" : ["width" : 120, "height" : 50]],
      ["title" : "Activity", "subtitle" : "", "kind" : "list", "size" : ["width" : 120, "height" : 50]],
      ["title" : "Radio", "subtitle" : "", "kind" : "list", "size" : ["width" : 120, "height" : 50]],
      ["title" : "Songs", "subtitle" : "", "kind" : "list", "size" : ["width" : 120, "height" : 50]],
      ["title" : "Albums", "subtitle" : "", "kind" : "list", "size" : ["width" : 120, "height" : 50]],
      ["title" : "Artists", "subtitle" : "", "kind" : "list", "size" : ["width" : 120, "height" : 50]],
      ["title" : "Stations", "subtitle" : "", "kind" : "list", "size" : ["width" : 120, "height" : 50]],
      ["title" : "Local files", "subtitle" : "", "kind" : "list", "size" : ["width" : 120, "height" : 50]]
    ]
    let rightViewItems: [[String : AnyObject]] = [
      ["title" : "Hello love", "subtitle" : "", "kind" : "grid", "size" : ["width" : 120, "height" : 120]],
      ["title" : "foo", "subtitle" : "", "kind" : "grid", "size" : ["width" : 120, "height" : 120]],
      ["title" : "bar", "subtitle" : "", "kind" : "grid", "size" : ["width" : 120, "height" : 120]],
      ["title" : "baz", "subtitle" : "", "kind" : "grid", "size" : ["width" : 120, "height" : 120]]
    ]

    let menuController = SpotsController(cacheKey: "menu-cache")
    menuController.reload([
      "components" : [
        ["kind" : "list", "items" : leftViewItems]
      ]
      ])
    let backgroundLayer = CALayer()
    backgroundLayer.backgroundColor = NSColor(red:0.157, green:0.157, blue:0.157, alpha: 1).CGColor
    menuController.spotsScrollView.layer = backgroundLayer

    let spotsController = SpotsController(cacheKey: "main-screen-cache")
    spotsController.reload([
      "components" : [
        ["kind" : "grid", "size" : ["height" : 88], "items" : rightViewItems
        ]
      ]
      ])
    let splitView = MainSplitView(leftView: menuController.view, rightView: spotsController.view)
    splitView.layer = CALayer()
    splitView.layer?.backgroundColor = NSColor.blackColor().CGColor
    splitView.wantsLayer = true

//    window.contentView = spotsController.view
    window.contentView = splitView
    window.becomeKeyWindow()
  }

  func applicationWillTerminate(aNotification: NSNotification) {
    // Insert code here to tear down your application
  }
}
