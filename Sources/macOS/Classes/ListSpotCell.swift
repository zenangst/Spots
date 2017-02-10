import Cocoa

class ListSpotCell: NSTableRowView, ItemConfigurable {

  var preferredViewSize: CGSize = CGSize(width: 0, height: 120)

  func configure(_ item: inout Item) {
    backgroundColor = NSColor.red
  }
}
