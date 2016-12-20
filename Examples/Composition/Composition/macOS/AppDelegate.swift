import Cocoa
import Spots

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  var windowController = NSWindowController(window: NSWindow())

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    windowController.window?.styleMask = [.closable, .borderless, .miniaturizable, .resizable, .titled, .fullSizeContentView]
    windowController.window?.minSize = NSSize(width: 960, height: 640)
    windowController.windowFrameAutosaveName = "Window"

    ListSpot.register(view: CompositionListView.self, identifier: "view")
    ListSpot.register(defaultView: CompositionListView.self)

    let controller = CompositionController()
    windowController.contentViewController = controller
    windowController.showWindow(nil)

    controller.reloadIfNeeded(CompositionController.components)
  }
}
