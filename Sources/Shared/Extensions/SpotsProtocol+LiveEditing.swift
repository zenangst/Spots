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

      source.setEventHandler(handler: {
        // Check that file still exists, otherwise cancel observering
        guard FileManager.default.fileExists(atPath: filePath) else {
          self.source.cancel()
          self.source = nil
          return
        }

        do {
          if let data = NSData(contentsOfFile: filePath),
            let json = try JSONSerialization.jsonObject(with: data as Data, options: .mutableContainers) as? [String : Any] {
            self.source.cancel()
            self.source = nil
            let offset = self.scrollView.contentOffset

            #if os(OSX)
              let components = json
            #else
              let components: [Component] = Parser.parse(json)
            #endif

            self.reloadIfNeeded(components) {
              self.scrollView.contentOffset = offset

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
            self.liveEditing(stateCache: self.stateCache)
          }
        } catch let error {
          self.source = nil

          print("Error: could not parse file")
          self.liveEditing(stateCache: self.stateCache)
        }
      })

      source.resume()
    }

    /// Enable live editing with state cache
    ///
    /// - parameter stateCache: An optional SpotCache, used for resolving which file should be monitored.
    func liveEditing(stateCache: SpotCache?) {
      #if (arch(i386) || arch(x86_64)) && os(iOS)
        guard let stateCache = stateCache, source == nil else { return }
      #else
        guard let stateCache = stateCache else { return }
      #endif
      CacheJSONOptions.writeOptions = .prettyPrinted

      let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
                                                      FileManager.SearchPathDomainMask.userDomainMask, true)
      print("🎍 SPOTS: Caching...")
      print("Cache key: \(stateCache.key)")
      print("File path: file://\(stateCache.path)\n")
      Dispatch.delay(for: 0.5) { self.monitor(filePath: stateCache.path) }
    }
  }
#endif
