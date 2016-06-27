import Cocoa
import Sugar

public class SpotsScrollView: NSScrollView {

  let KVOContext = UnsafeMutablePointer<()>(nil)

  private var subviewsInLayoutOrder = [NSView]()

  public var forceUpdate = false {
    didSet {
      if forceUpdate {
        layoutSubtreeIfNeeded()
      }
    }
  }

  lazy public var spotsContentView: SpotsContentView = SpotsContentView().then {
    $0.autoresizingMask = [.ViewWidthSizable, .ViewHeightSizable]
    $0.autoresizesSubviews = true
  }

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    self.documentView = spotsContentView
    drawsBackground = false
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func allowsKeyedCoding() -> Bool {
    return true
  }

  func didAddSubviewToContainer(subview: View) {
    subviewsInLayoutOrder.append(subview)
    layoutSubtreeIfNeeded()

    guard let scrollView = subview as? ScrollView where scrollView.superview?.superview == contentView else {
      return
    }

    scrollView.addObserver(self, forKeyPath: "frame", options: .Old, context: KVOContext)
  }

  public override func willRemoveSubview(subview: View) {
    if let scrollView = subview as? ScrollView where scrollView.superview?.superview == contentView {
      scrollView.removeObserver(self, forKeyPath: "frame", context: KVOContext)
    }

    if let index = subviewsInLayoutOrder.indexOf({ $0 == subview }) {
      subviewsInLayoutOrder.removeAtIndex(index)
      layoutSubtreeIfNeeded()
    }
  }

  public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if let window = object as? NSWindow {
      layoutSubtreeIfNeeded()
    } else if let change = change, scrollView = object as? ScrollView,
      oldValue = (change[NSKeyValueChangeOldKey] as? NSValue)?.rectValue where context == KVOContext {
      guard scrollView.frame != oldValue else { return }
      layoutSubtreeIfNeeded()
    }
  }

  static public override func isCompatibleWithResponsiveScrolling() -> Bool {
    return true
  }

  override public func layoutSubtreeIfNeeded() {
    guard let window = window else { return }
    super.layoutSubtreeIfNeeded()

    let contentOffset = self.contentOffset
    var yOffsetOfCurrentSubview: CGFloat = 0.0

    for case let scrollView as ScrollView in subviewsInLayoutOrder {
      var frame = scrollView.frame
      var contentOffset = scrollView.contentOffset

      if self.contentOffset.y <= yOffsetOfCurrentSubview {
        contentOffset.y = 0.0
        frame.origin.y = yOffsetOfCurrentSubview
      }

      frame.size.width = ceil(contentView.frame.size.width)
      scrollView.frame = frame
      scrollView.contentOffset = contentOffset

      yOffsetOfCurrentSubview += scrollView.frame.height
    }

    guard frame.height > 0 && frame.width > 100 else { return }

    documentView?.setFrameSize(CGSize(width: frame.size.width, height: fmax(yOffsetOfCurrentSubview, frame.height)))
    displayIfNeeded()
    
    if let view = superview {
      view.layout()
    }
  }
}
