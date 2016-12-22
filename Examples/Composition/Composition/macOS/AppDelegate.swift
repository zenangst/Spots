import Cocoa
import Spots

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  var windowController = NSWindowController(window: NSWindow())

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    windowController.windowFrameAutosaveName = "Window"

    windowController.window?.styleMask = [.closable, .borderless, .miniaturizable, .resizable, .titled, .fullSizeContentView]
    windowController.window?.minSize = NSSize(width: 640, height: 650)
    windowController.window?.titlebarAppearsTransparent = true
    windowController.window?.isMovable = true
    windowController.window?.isOpaque = false
    windowController.window?.titleVisibility = .hidden
    windowController.window?.backgroundColor = NSColor(red:1.0, green:1.0, blue:1.0, alpha: 0.985)

    CarouselSpot.register(view: FeaturedCell.self, identifier: "featured")
    CarouselSpot.register(view: GridCell.self, identifier: "default")

    GridSpot.register(view: FeaturedCell.self, identifier: "featured")
    GridSpot.register(view: GridCell.self, identifier: "default")
    GridSpot.register(defaultView: GridCell.self)

    ListSpot.register(view: CompositionListView.self, identifier: "view")
    ListSpot.register(view: ListCell.self, identifier: "default")
    ListSpot.register(defaultView: ListCell.self)

    CarouselSpot.configure = { collectionView in
      collectionView.backgroundView?.layer?.backgroundColor = NSColor.white.cgColor
    }
    
    GridSpot.configure = { collectionView in
      collectionView.backgroundView?.layer?.backgroundColor = NSColor.white.cgColor
    }

    ListSpot.configure = { tableView in
      tableView.backgroundColor = NSColor.white
    }

    Spots.Controller.configure = { scrollView in
      scrollView.backgroundColor = NSColor.white
    }

    let controller = CompositionController()
    windowController.contentViewController = controller
    windowController.showWindow(nil)

    controller.reloadIfNeeded(CompositionController.components)
  }
}
