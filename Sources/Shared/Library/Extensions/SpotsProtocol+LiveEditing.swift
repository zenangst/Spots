import Foundation
import Sugar
import Cache

#if DEVMODE
  public extension SpotsProtocol {

    private func monitor(filePath: String) {
      guard NSFileManager.defaultManager().fileExistsAtPath(filePath) else { return }

      source = dispatch_source_create(
        DISPATCH_SOURCE_TYPE_VNODE,
        UInt(open(filePath, O_EVTONLY)),
        DISPATCH_VNODE_DELETE | DISPATCH_VNODE_WRITE | DISPATCH_VNODE_EXTEND | DISPATCH_VNODE_ATTRIB | DISPATCH_VNODE_LINK | DISPATCH_VNODE_RENAME | DISPATCH_VNODE_REVOKE,
        fileQueue)

      dispatch_source_set_event_handler(source, {
        // Check that file still exists, otherwise cancel observering
        guard NSFileManager.defaultManager().fileExistsAtPath(filePath) else {
          dispatch_source_cancel(self.source)
          self.source = nil
          return
        }

        do {
          if let data = NSData(contentsOfFile: filePath),
            json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [String : AnyObject] {
            dispatch_source_cancel(self.source)
            self.source = nil
            let offset = self.spotsScrollView.contentOffset
            self.reloadIfNeeded(json, compare: { $0 !== $1 }) {
              self.spotsScrollView.contentOffset = offset

              var yOffset: CGFloat = 0.0
              for spot in self.spots {
                (spot as? Gridable)?.layout.yOffset = yOffset
                yOffset += spot.render().frame.size.height
              }

              for case let gridable as CarouselSpot in self.spots {
                (gridable.layout as? GridableLayout)?.yOffset = gridable.render().frame.origin.y
              }
            }
          }
        } catch let error {
          self.source = nil
          self.liveEditing(self.stateCache)
        }
      })

      dispatch_resume(source)
    }

    private func liveEditing(stateCache: SpotCache?) {
      #if os(iOS)
        guard let stateCache = stateCache where source == nil && Simulator.isRunning else { return }
      #else
        guard let stateCache = stateCache else { return }
      #endif
      CacheJSONOptions.writeOptions = .PrettyPrinted

      let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory,
                                                      NSSearchPathDomainMask.UserDomainMask, true)
      NSLog("-----[\(stateCache.key)]-----\n\nfile://\(stateCache.path)\n\n")
      delay(0.5) { self.monitor(stateCache.path) }
    }
  }
#endif
