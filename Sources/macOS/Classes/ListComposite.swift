import Cocoa

/// A proxy cell that is used for composite views inside other components.
public class ListComposite: NSTableRowView, Composable {

  /// A required content view, needed because of Composable extensions
  public var contentView: View {
    return self
  }

  static open var isFlipped: Bool {
    return true
  }
}
