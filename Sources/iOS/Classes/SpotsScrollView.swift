import UIKit
import QuartzCore

/// The core foundation scroll view inside of Spots that manages the linear layout of all Spotable objects
open class SpotsScrollView: UIScrollView {

  /// A KVO context used to monitor changes in contentSize, frames and bounds
  let subviewContext: UnsafeMutableRawPointer? = UnsafeMutableRawPointer(mutating: nil)

  /// A collection of UIView's that resemble the order of the views in the scroll view
  fileprivate var subviewsInLayoutOrder = [UIView?]()

  /// The distance that the content view is inset from the enclosing scroll view.
  open override var contentInset: UIEdgeInsets {
    willSet {
      if self.isTracking {
        let diff = newValue.top - self.contentInset.top
        var translation = self.panGestureRecognizer.translation(in: self)
        translation.y -= diff * 3.0 / 2.0
        self.panGestureRecognizer.setTranslation(translation, in: self)
      }
    }
  }

  /// A container view that works as a proxy layer for scroll view
  open var contentView: SpotsContentView = SpotsContentView()


  /// A deinitiazlier that removes all subviews from contentView
  deinit {
    for subview in subviewsInLayoutOrder {
      if let subview = subview {
        unobserveView(view: subview)
      }
    }

    subviewsInLayoutOrder.removeAll()
  }

  /// Initializes and returns a newly allocated view object with the specified frame rectangle.
  ///
  /// - parameter frame: The frame rectangle for the view, measured in points. The origin of the frame is relative to the superview in which you plan to add it.
  ///  This method uses the frame rectangle to set the center and bounds properties accordingly.
  ///
  /// - returns: An initialized spots scroll view
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.autoresizingMask = self.autoresizingMask
    addSubview(contentView)
  }

  /// Returns an object initialized from data in a given unarchiver.
  ///
  /// - parameter coder: An unarchiver object.
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// A method to setup KVO observers on views added to contentView
  ///
  /// - parameter subview: - parameter subview: The view to add to the view as a subview..
  func didAddSubviewToContainer(_ subview: UIView) {
    subview.autoresizingMask = UIViewAutoresizing()

    guard let index = contentView.subviews.index(of: subview) else { return }

    subviewsInLayoutOrder.removeAll()
    for subview in contentView.subviews {
      subviewsInLayoutOrder.append(subview)
      observeView(view: subview)
    }

    guard let scrollView = subview as? UIScrollView else {
      setNeedsLayout()
      return
    }

    #if os(iOS)
      scrollView.scrollsToTop = false
    #endif
    scrollView.isScrollEnabled = false

    if let collectionView = scrollView as? UICollectionView,
      let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout, layout.scrollDirection == .horizontal {
      scrollView.isScrollEnabled = true
    }
    setNeedsLayout()
    layoutSubviews()
  }

  /// Tells the view that a subview is about to be removed.
  ///
  /// - parameter subview: - parameter subview: The subview that will be removed.
  open override func willRemoveSubview(_ subview: UIView) {
    unobserveView(view: subview)

    if let index = subviewsInLayoutOrder.index(where: { $0 == subview }) {
      subviewsInLayoutOrder.remove(at: index)
    }

    setNeedsLayout()
    layoutSubviews()
  }

  /// Remove observers from subview.
  ///
  /// - Parameter subview: The subview that should no longer be observed.
  private func observeView(view: UIView) {
    if view is UIScrollView && view.superview == contentView {
      view.addObserver(self, forKeyPath: #keyPath(contentSize), options: .old, context: subviewContext)
      view.addObserver(self, forKeyPath: #keyPath(contentOffset), options: .old, context: subviewContext)
    } else if view.superview == contentView {
      view.addObserver(self, forKeyPath: #keyPath(frame), options: .old, context: subviewContext)
      view.addObserver(self, forKeyPath: #keyPath(bounds), options: .old, context: subviewContext)
    }
  }

  private func unobserveView(view: UIView) {
    if view is UIScrollView && view.superview == contentView {
      view.removeObserver(self, forKeyPath: #keyPath(contentSize), context: subviewContext)
      view.removeObserver(self, forKeyPath: #keyPath(contentOffset), context: subviewContext)
    } else if view.superview == contentView {
      view.removeObserver(self, forKeyPath: #keyPath(frame), context: subviewContext)
      view.removeObserver(self, forKeyPath: #keyPath(bounds), context: subviewContext)
    }
  }

  /// This message is sent to the receiver when the value at the specified key path relative to the given object has changed.
  ///
  /// - parameter keyPath: The key path, relative to object, to the value that has changed.
  /// - parameter object:  The source object of the key path keyPath.
  /// - parameter change:  A dictionary that describes the changes that have been made to the value of the property at the key path keyPath relative to object.
  /// - parameter context: The value that was provided when the receiver was registered to receive key-value observation notifications.
  open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    guard let keyPath = keyPath else { return }

    if let change = change, context == subviewContext {
      if let scrollView = object as? UIScrollView {
        guard let newValue = change[NSKeyValueChangeKey.oldKey] else { return }
        if #keyPath(contentSize) == keyPath {

          let newContentSize = scrollView.contentSize
          let oldContentSize = (newValue as AnyObject).cgSizeValue
          if !compare(size: newContentSize, to: oldContentSize) {
            setNeedsLayout()
            layoutIfNeeded()
          }
        } else if #keyPath(contentOffset) == keyPath
          && (isDragging == false && isTracking == false) {
          let oldOffset = (newValue as AnyObject).cgPointValue
          let newOffset = scrollView.contentOffset

          if !compare(point: newOffset, to: oldOffset) {
            setNeedsLayout()
            layoutIfNeeded()
          }
        }
      } else if let view = object as? UIView {
        let oldFrame = (change[NSKeyValueChangeKey.oldKey] as AnyObject).cgRectValue
        let newFrame = view.frame

        if !compare(rect: newFrame, to: oldFrame) {
          setNeedsLayout()
          layoutIfNeeded()
        }
      }
    } else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
  }

  /// Layout views in linear order based of view index in `subviewsInLayoutOrder`
  func layoutViews() {
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
        frame.size.width = ceil(contentView.frame.size.width) - scrollView.contentInset.left - scrollView.contentInset.right
        frame.origin.x = scrollView.contentInset.left

        scrollView.frame = frame.integral
        scrollView.contentOffset = CGPoint(x: Int(contentOffset.x), y: Int(contentOffset.y))

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
    contentSize = CGSize(width: bounds.size.width, height: fmax(yOffsetOfCurrentSubview, minimumContentHeight))

    if self.frame.size.height != superview.frame.size.height {
      self.frame.size.height = superview.frame.size.height
    }
  }

  /// A custom implementation of layoutSubviews that handles the scrolling of all the underlaying views within the container.
  /// It does this by iterating over subviewsInLayoutOrder and sets the current offset for each individual view within the container.
  open override func layoutSubviews() {
    super.layoutSubviews()

    let initialContentOffset = contentOffset
    layoutViews()

    guard !initialContentOffset.equalTo(contentOffset) else { return }
    setNeedsLayout()
    layoutIfNeeded()
  }

  /// Compare points
  ///
  /// - parameter p1: Left hand side CGPoint
  /// - parameter p2: Right hand side CGPoint
  ///
  /// - returns: A boolean value, true if they are equal
  private func compare(point lhs: CGPoint, to rhs: CGPoint?) -> Bool {
    guard let rhs = rhs else { return false }
    return Int(lhs.x) == Int(rhs.x) && Int(lhs.y) == Int(rhs.y)
  }

  /// Compare sizes
  ///
  /// - parameter p1: Left hand side CGPoint
  /// - parameter p2: Right hand side CGPoint
  ///
  /// - returns: A boolean value, true if they are equal
  private func compare(size lhs: CGSize, to rhs: CGSize?) -> Bool {
    guard let rhs = rhs else { return false }
    return Int(lhs.width) == Int(rhs.width) && Int(lhs.height) == Int(rhs.height)
  }

  /// Compare rectangles
  ///
  /// - parameter lhs: Left hand side CGRect
  /// - parameter rhs: Right hand side CGRect
  ///
  /// - returns: A boolean value, true if they are equal
  private func compare(rect lhs: CGRect, to rhs: CGRect?) -> Bool {
    guard let rhs = rhs else { return false }
    return lhs.integral.equalTo(rhs.integral)
  }
}
