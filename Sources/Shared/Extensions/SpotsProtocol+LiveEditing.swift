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
        guard let strongSelf = self, FileManager.default.fileExists(atPath: filePath) else {
          self?.source?.cancel()
          self?.source = nil
          return
        }

        do {
          if let data = NSData(contentsOfFile: filePath),
            let json = try JSONSerialization.jsonObject(with: data as Data, options: .mutableContainers) as? [String : Any] {
            strongSelf.source?.cancel()
            strongSelf.source = nil

            let offset = strongSelf.scrollView.contentOffset
            let components: [ComponentModel] = Parser.parse(json)

            strongSelf.reloadIfNeeded(components) {
              strongSelf.scrollView.contentOffset = offset

              var yOffset: CGFloat = 0.0
              for component in strongSelf.components {
                #if !os(OSX)
                (component as? CarouselComponent)?.layout.yOffset = yOffset
                #endif
                yOffset += component.view.frame.size.height
              }

              #if !os(OSX)
              for case let gridable as CarouselComponent in strongSelf.components {
                gridable.layout.yOffset = gridable.view.frame.origin.y
              }
              #endif
            }
            print("🎍 SPOTS reloaded: \(strongSelf.components.count) -> items: \(strongSelf.components.reduce(0, { $0.1.items.count }))")
            strongSelf.liveEditing(stateCache: strongSelf.stateCache)
          }
        } catch _ {
          strongSelf.source = nil

          print("⛔️ Error: could not parse file")
          strongSelf.liveEditing(stateCache: strongSelf.stateCache)
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
      Dispatch.after(seconds: 0.5) { [weak self] in self?.monitor(filePath: stateCache.path) }
    }
  }
#endif
