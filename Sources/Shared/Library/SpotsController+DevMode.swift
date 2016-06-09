#if DEVMODE
import Sugar

extension SpotsController {

  func monitor(filePath: String) {
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
          guard let spot = spot(index, Spotable.self) where !(spot.items === items) else {
            self.cache()
            return
          }

          self.update(spotAtIndex: index, withCompletion: completion, {
            $0.items = items
            self.cache()
          })
        }
      } catch let error {
        dispatch_source_cancel(self.source)
        self.source = nil

        self.reload(["components" : [["kind" : "list", "items" : [[
          "title" : "JSON parsing error",
          "subtitle" : "\(error)"]]
          ]
          ]])
      }
    })

    dispatch_resume(source)
  }
}
#endif
