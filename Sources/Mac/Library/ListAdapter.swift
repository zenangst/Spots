import Cocoa

public class ListAdapter : NSObject {
  // An unowned Gridable object
  var spot: Spotable

  /**
   Initialization a new instance of a CollectionAdapter using a Gridable object

   - Parameter gridable: A Gridable object
   */
  init(spot: Spotable) {
    self.spot = spot
  }
}

extension ListAdapter: NSTableViewDataSource {

  public func tableView(tableView: NSTableView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, row: Int) {
    
  }

  public func numberOfRowsInTableView(tableView: NSTableView) -> Int {
    return spot.component.items.count
  }

  public func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
    return false
  }

  public func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
    return true
  }
  
  public func tableView(tableView: NSTableView, shouldSelectTableColumn tableColumn: NSTableColumn?) -> Bool {
    return false
  }
}

extension ListAdapter: NSTableViewDelegate {

  public func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
    spot.component.size = CGSize(
      width: tableView.frame.width,
      height: tableView.frame.height)

    let height = row < spot.component.items.count ? spot.item(row).size.height : 0.0

    return height
  }
  
  public func tableView(tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
    let reuseIdentifier = spot.reuseIdentifierForItem(row)
    let view = spot.dynamicType.views[reuseIdentifier]
    let rowView = view?.init()

    (rowView as? SpotConfigurable)?.configure(&spot.component.items[row])
    
    if let rowView = rowView as? NSTableRowView {
      return rowView
    }

    return nil
  }

  public func tableView(tableView: NSTableView, willDisplayCell cell: AnyObject, forTableColumn tableColumn: NSTableColumn?, row: Int) {
    print("will display cell")
  }

  public func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
    print("viewForTableColumn")
    return nil
  }

  
  
}