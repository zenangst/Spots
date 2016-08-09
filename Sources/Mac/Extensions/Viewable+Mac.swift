import Cocoa

public extension Viewable {

  public var responder: NSResponder {
    return scrollView
  }

  public var nextResponder: NSResponder? {
    get {
      return nil
    }
    set {}
  }
}
