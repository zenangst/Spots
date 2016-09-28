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

            #if os(OSX)
              let components = json
            #else
              let components: [Component] = Parser.parse(json)
            #endif

            self.reloadIfNeeded(components) {
              self.spotsScrollView.contentOffset = offset

              var yOffset: CGFloat = 0.0
              for spot in self.spots {
                #if !os(OSX)
                (spot as? Gridable)?.layout.yOffset = yOffset
                #endif
                yOffset += spot.render().frame.size.height
              }

              #if !os(OSX)
              for case let gridable as CarouselSpot in self.spots {
                (gridable.layout as? GridableLayout)?.yOffset = gridable.render().frame.origin.y
              }
              #endif
            }
            print("Spots reloaded: \(self.spots.count)")
            self.liveEditing(self.stateCache)
          }
        } catch let error {
          self.source = nil

          print("Error: could not parse file")
          self.liveEditing(self.stateCache)
        }
      })

      dispatch_resume(source)
    }

    func liveEditing(stateCache: SpotCache?) {
      #if (arch(i386) || arch(x86_64)) && os(iOS)
        guard let stateCache = stateCache where source == nil else { return }
      #else
        guard let stateCache = stateCache else { return }
      #endif
      CacheJSONOptions.writeOptions = .PrettyPrinted

      let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory,
                                                      NSSearchPathDomainMask.UserDomainMask, true)
      print("🎍 SPOTS: Caching...")
      print("Cache key: \(stateCache.key)")
      print("File path: file://\(stateCache.path)\n")
      Dispatch.delay(for: 0.5) { self.monitor(stateCache.path) }
    }
  }
#endif
