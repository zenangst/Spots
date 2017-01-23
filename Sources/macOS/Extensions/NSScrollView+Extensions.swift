import Cocoa

extension NSScrollView {

  public var contentOffset: CGPoint {
    get {
      return documentVisibleRect.origin
    }
    set(newValue) {
      documentView?.scroll(newValue)
    }
  }
}
