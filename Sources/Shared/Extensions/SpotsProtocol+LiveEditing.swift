#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif

import Cache

#if DEVMODE
  public extension SpotsProtocol {

    /// Monitor changes made to a file at file path.
    ///
    /// - parameter filePath: A file path string, pointing to the file that should be monitored.
    private func monitor(filePath: String) {
      guard FileManager.default.fileExists(atPath: filePath) else { return }

      let eventMask: DispatchSource.FileSystemEvent = [.delete, .write, .extend, .attrib, .link, .rename, .revoke]
      source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: Int32(open(filePath, O_EVTONLY)),
                                                         eventMask: eventMask,
                                                         queue: fileQueue)

      source?.setEventHandler(handler: { [weak self] in
        // Check that file still exists, otherwise cancel observering
        guard let weakSelf = self, FileManager.default.fileExists(atPath: filePath) else {
          self?.source?.cancel()
          self?.source = nil
          return
        }

        do {
          if let data = NSData(contentsOfFile: filePath),
            let json = try JSONSerialization.jsonObject(with: data as Data, options: .mutableContainers) as? [String : Any] {
            weakSelf.source?.cancel()
            weakSelf.source = nil
            let offset = weakSelf.scrollView.contentOffset

            #if os(OSX)
              let components = json
            #else
              let components: [Component] = Parser.parse(json)
            #endif

            weakSelf.reloadIfNeeded(components) {
              weakSelf.scrollView.contentOffset = offset

              var yOffset: CGFloat = 0.0
              for spot in weakSelf.spots {
                #if !os(OSX)
                (spot as? CarouselSpot)?.layout.yOffset = yOffset
                #endif
                yOffset += spot.render().frame.size.height
              }

              #if !os(OSX)
              for case let gridable as CarouselSpot in weakSelf.spots {
                gridable.layout.yOffset = gridable.render().frame.origin.y
              }
              #endif
            }
            print("🎍 Spots reloaded: \(weakSelf.spots.count)")
            weakSelf.liveEditing(stateCache: weakSelf.stateCache)
          }
        } catch _ {
          weakSelf.source = nil

          print("⚠️ Error: could not parse file")
          weakSelf.liveEditing(stateCache: weakSelf.stateCache)
        }
      })

      source?.resume()
    }

    /// Enable live editing with state cache
    ///
    /// - parameter stateCache: An optional StateCache, used for resolving which file should be monitored.
    func liveEditing(stateCache: StateCache?) {
      #if (arch(i386) || arch(x86_64)) && os(iOS)
        guard let stateCache = stateCache, source == nil else { return }
      #else
        guard let stateCache = stateCache else { return }
      #endif
      CacheJSONOptions.writeOptions = .prettyPrinted
      print("🎍 SPOTS: Caching...")
      print("Cache key: \(stateCache.key)")
      print("File path: file://\(stateCache.path)\n")
      Dispatch.delay(for: 0.5) { [weak self] in self?.monitor(filePath: stateCache.path) }
    }
  }
#endif
