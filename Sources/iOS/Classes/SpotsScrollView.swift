import UIKit
import QuartzCore

public class SpotsScrollView: UIScrollView {

  enum ObservedKeypath: String {
    case ContentOffset = "contentOffset"
    case ContentSize   = "contentSize"
    case Frame         = "frame"
    case Bounds        = "bounds"
  }

  /// A KVO context used to monitor changes in contentSize, frames and bounds
  let subviewContext = UnsafeMutablePointer<()>(nil)

  /// An collection of UIView's that resemble the order of the views in the scroll view
  private var subviewsInLayoutOrder = [UIView?]()

  /// The distance that the content view is inset from the enclosing scroll view.
  public override var contentInset: UIEdgeInsets {
    willSet {
      if self.tracking {
        let diff = newValue.top - self.contentInset.top
        var translation = self.panGestureRecognizer.translationInView(self)
        translation.y -= diff * 3.0 / 2.0
        self.panGestureRecognizer.setTranslation(translation, inView: self)
      }
    }
  }

  /// A container view that works as a proxy layer for scroll view
  lazy public var contentView: SpotsContentView = SpotsContentView()

  /**
   A deinitiazlier that removes all subviews from contentView
   */
  deinit {
    contentView.subviews.forEach { $0.removeFromSuperview() }
  }

  /**
   Initializes and returns a newly allocated view object with the specified frame rectangle.
   An initialized view object.

   - parameter frame: The frame rectangle for the view, measured in points. The origin of the frame is relative to the superview in which you plan to add it.
   This method uses the frame rectangle to set the center and bounds properties accordingly.
   */
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.autoresizingMask = self.autoresizingMask
    addSubview(contentView)
  }

  /**
   Returns an object initialized from data in a given unarchiver.

   - parameter aDecoder: An unarchiver object.
   */
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /**
   A method to setup KVO observers on views added to contentView

   - parameter subview: The view to add to the view as a subview.
   */
  func didAddSubviewToContainer(subview: UIView) {
    subview.autoresizingMask = [.None]

    guard let index = contentView.subviews.indexOf(subview) else { return }
    subviewsInLayoutOrder.insert(subview, atIndex: index)

    if subview.superview == contentView && !(subview is UIScrollView) {
      subview.addObserver(self, forKeyPath: ObservedKeypath.Frame.rawValue, options: .Old, context: subviewContext)
      subview.addObserver(self, forKeyPath: ObservedKeypath.Bounds.rawValue, options: .Old, context: subviewContext)
    }

    guard let scrollView = subview as? UIScrollView else {
      setNeedsLayout()
      return
    }

    #if os(iOS)
      scrollView.scrollsToTop = false
    #endif
    scrollView.scrollEnabled = false

    if let collectionView = scrollView as? UICollectionView,
      layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
      where layout.scrollDirection == .Horizontal {
      scrollView.scrollEnabled = true
    }

    scrollView.addObserver(self, forKeyPath: ObservedKeypath.ContentSize.rawValue, options: .Old, context: subviewContext)
    scrollView.addObserver(self, forKeyPath: ObservedKeypath.ContentOffset.rawValue, options: .Old, context: subviewContext)

    setNeedsLayout()
  }

  /**
   Tells the view that a subview is about to be removed.

   - parameter subview: The subview that will be removed.
   */
  public override func willRemoveSubview(subview: UIView) {
    if subview is UIScrollView && subview.superview == contentView {
      subview.removeObserver(self, forKeyPath: ObservedKeypath.ContentSize.rawValue, context: subviewContext)
      subview.removeObserver(self, forKeyPath: ObservedKeypath.ContentOffset.rawValue, context: subviewContext)
    } else if subview.superview == contentView {
      subview.removeObserver(self, forKeyPath: ObservedKeypath.Frame.rawValue, context: subviewContext)
      subview.removeObserver(self, forKeyPath: ObservedKeypath.Bounds.rawValue, context: subviewContext)
    }

    if let index = subviewsInLayoutOrder.indexOf({ $0 == subview }) {
      subviewsInLayoutOrder.removeAtIndex(index)
    }

    setNeedsLayout()
  }

  /**
   This message is sent to the receiver when the value at the specified key path relative to the given object has changed.

   - parameter keyPath: The key path, relative to object, to the value that has changed.
   - parameter object:  The source object of the key path keyPath.
   - parameter change:  A dictionary that describes the changes that have been made to the value of the property at the key path keyPath relative to object.
   - parameter context: The value that was provided when the receiver was registered to receive key-value observation notifications.
   */
  public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if let change = change where context == subviewContext {
      if let scrollView = object as? UIScrollView {
        guard let change = change[NSKeyValueChangeOldKey] else { return }
        if keyPath == ObservedKeypath.ContentSize.rawValue {
          let oldContentSize = change.CGSizeValue()
          let newContentSize = scrollView.contentSize
          if !CGSizeEqualToSize(newContentSize, oldContentSize) {
            setNeedsLayout()
            layoutIfNeeded()
          }
        } else if keyPath == ObservedKeypath.ContentOffset.rawValue {
          let oldOffset = change.CGPointValue()
          let newOffset = scrollView.contentOffset
          if !CGPointEqualToPoint(newOffset, oldOffset) {
            setNeedsLayout()
            layoutIfNeeded()
          }
        }
      } else if let view = object as? UIView,
        oldFrame = change[NSKeyValueChangeOldKey]?.CGRectValue() {
        let newFrame = view.frame

        if (!CGRectEqualToRect(newFrame, oldFrame)) {
          self.setNeedsLayout()
          self.layoutIfNeeded()
        }
      }
    } else {
      super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
    }
  }

  /**
   A custom implementation of layoutSubviews that handles the scrolling of all the underlaying views within the container.
   It does this by iterating over subviewsInLayoutOrder and sets the current offset for each individual view within the container.
   */
  public override func layoutSubviews() {
    super.layoutSubviews()

    guard let superview = superview else { return }

    contentView.frame = bounds
    contentView.bounds = CGRect(origin: contentOffset, size: bounds.size)

    var yOffsetOfCurrentSubview: CGFloat = 0.0

    for subview in subviewsInLayoutOrder {
      if let scrollView = subview as? UIScrollView {
        var frame = scrollView.frame
        var contentOffset = scrollView.contentOffset

        if self.contentOffset.y < yOffsetOfCurrentSubview {
          contentOffset.y = 0.0
          frame.origin.y = yOffsetOfCurrentSubview
        } else {
          contentOffset.y = self.contentOffset.y - yOffsetOfCurrentSubview
          frame.origin.y = self.contentOffset.y
        }

        let remainingBoundsHeight = fmax(bounds.maxY - frame.minY, 0.0)
        let remainingContentHeight = fmax(scrollView.contentSize.height - contentOffset.y, 0.0)

        frame.size.height = ceil(fmin(remainingBoundsHeight, remainingContentHeight))
        frame.size.width = ceil(contentView.frame.size.width)

        scrollView.frame = frame
        scrollView.contentOffset = contentOffset

        yOffsetOfCurrentSubview += scrollView.contentSize.height + scrollView.contentInset.top + scrollView.contentInset.bottom
      } else if let subview = subview {
        var frame = subview.frame
        frame.origin.x = 0
        frame.origin.y = yOffsetOfCurrentSubview
        frame.size.width = contentView.bounds.size.width
        subview.frame = frame

        yOffsetOfCurrentSubview += frame.size.height
      }
    }

    let minimumContentHeight = bounds.height - (contentInset.top + contentInset.bottom)
    let initialContentOffset = contentOffset
    contentSize = CGSize(width: bounds.size.width, height: fmax(yOffsetOfCurrentSubview, minimumContentHeight))

    if self.frame.size.height != superview.frame.size.height {
      self.frame.size.height = superview.frame.size.height
    }

    guard initialContentOffset != contentOffset else { return }
    setNeedsLayout()
    layoutIfNeeded()
  }
}
