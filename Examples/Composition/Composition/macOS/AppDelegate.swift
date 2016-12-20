import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  var windowController = NSWindowController(window: NSWindow())

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    windowController.window?.styleMask = [.closable, .borderless, .miniaturizable, .resizable, .titled, .fullSizeContentView]
    windowController.window?.minSize = NSSize(width: 985, height: 640)

    let controller = CompositionController()
    windowController.contentViewController = controller
    windowController.showWindow(nil)
  }

}

