import UIKit
import QuartzCore

/// The core foundation scroll view inside of Spots that manages the linear layout of all components.
open class SpotsScrollView: UIScrollView, UIGestureRecognizerDelegate {
  var sizeCache = [Int: CGFloat]()
  var isRotating = false

  private struct Observer: Equatable {
    let view: UIView
    let keyValueObservation: NSKeyValueObservation

    static func == (lhs: Observer, rhs: Observer) -> Bool {
      return lhs.view === rhs.view && lhs.keyValueObservation === rhs.keyValueObservation
    }
  }

  /// A collection of UIView's that resemble the order of the views in the scroll view
  var subviewsInLayoutOrder = [UIView]()
  private var observers = [Observer]()

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
  open var componentsView: SpotsContentView = SpotsContentView()

  let configuration: Configuration

  /// A deinitiazlier that removes all subviews from contentView
  deinit {
    subviewsInLayoutOrder.removeAll()
    observers.removeAll()
  }

  /// Initializes and returns a newly allocated view object with the specified frame rectangle.
  ///
  /// - parameter frame: The frame rectangle for the view, measured in points. The origin of the frame is relative to the superview in which you plan to add it.
  ///  This method uses the frame rectangle to set the center and bounds properties accordingly.
  ///
  /// - returns: An initialized components scroll view
  public required init(frame: CGRect, configuration: Configuration) {
    self.configuration = configuration
    super.init(frame: frame)
    componentsView.autoresizingMask = self.autoresizingMask
    addSubview(componentsView)
  }

  /// Returns an object initialized from data in a given unarchiver.
  ///
  /// - parameter coder: An unarchiver object.
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open override func didMoveToSuperview() {
    super.didMoveToSuperview()

    guard let superview = superview else {
      return
    }

    if frame.size.height != superview.frame.size.height {
      frame.size.height = superview.frame.size.height
    }
  }

  /// A method to setup KVO observers on views added to contentView
  ///
  /// - parameter subview: - parameter subview: The view to add to the view as a subview..
  func didAddSubviewToContainer(_ subview: UIView) {
    subview.autoresizingMask = UIViewAutoresizing()

    guard componentsView.subviews.index(of: subview) != nil else {
      return
    }

    observeView(view: subview)

    subviewsInLayoutOrder.removeAll()
    for subview in componentsView.subviews {
      subviewsInLayoutOrder.append(subview)
    }

    guard let scrollView = subview as? UIScrollView else {
      setNeedsLayout()
      return
    }

    #if os(iOS)
      scrollView.scrollsToTop = false
      if let collectionView = scrollView as? UICollectionView,
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout, layout.scrollDirection == .horizontal {
        scrollView.isScrollEnabled = true
      } else {
        scrollView.isScrollEnabled = false
      }
    #else
      if subviewsInLayoutOrder.count > 1 {
        for case let scrollView as ScrollView in subviewsInLayoutOrder {
          scrollView.isScrollEnabled = (scrollView as? UICollectionView)?.flowLayout?.scrollDirection == .horizontal
        }
      } else {
        scrollView.isScrollEnabled = true
      }
    #endif

    computeContentSize()
    setNeedsLayout()
    layoutSubviews()
  }

  /// Tells the view that a subview is about to be removed.
  ///
  /// - parameter subview: - parameter subview: The subview that will be removed.
  open override func willRemoveSubview(_ subview: UIView) {
    if let index = subviewsInLayoutOrder.index(where: { $0 == subview }) {
      subviewsInLayoutOrder.remove(at: index)
    }

    for observer in observers.filter({ $0.view === subview }) {
      if let index = observers.index(where: { $0 == observer }) {
        observers.remove(at: index)
      }
    }

    computeContentSize()
    setNeedsLayout()
    layoutSubviews()
  }

  /// Remove observers from subview.
  ///
  /// - Parameter subview: The subview that should no longer be observed.
  private func observeView(view: UIView) {
    guard view.superview == componentsView else {
      return
    }

    switch view {
    case let scrollView as UIScrollView:
      let contentSizeObserver = scrollView.observe(\.contentSize, options: [.initial, .new, .old], changeHandler: { [weak self] (scrollView, value) in
        guard let strongSelf = self, let newValue = value.newValue else {
          return
        }

        if scrollView.contentSize != newValue {
          strongSelf.computeContentSize()
          strongSelf.layoutViews()
        }
      })

      let contentOffsetObserver = scrollView.observe(\.contentOffset, options: [.new, .old], changeHandler: { [weak self] (_, value) in
        guard let strongSelf = self, let newValue = value.newValue else {
          return
        }

        guard let oldValue = value.oldValue else {
          strongSelf.layoutViews()
          return
        }

        if newValue.y != oldValue.y {
          strongSelf.layoutViews()
        }
      })

      observers.append(Observer(view: view, keyValueObservation: contentSizeObserver))
      observers.append(Observer(view: view, keyValueObservation: contentOffsetObserver))
      fallthrough
    default:
      let boundsObserver = view.observe(\.bounds, options: [.new, .old], changeHandler: { [weak self] (_, value) in
        guard let strongSelf = self, let newValue = value.newValue else {
          return
        }

        guard let oldValue = value.oldValue else {
          strongSelf.layoutViews()
          return
        }

        if newValue.origin.y != oldValue.origin.y {
          strongSelf.layoutViews()
        }
      })

      observers.append(Observer(view: view, keyValueObservation: boundsObserver))
    }
  }

  private func computeContentSize() {
    let computedHeight = subviewsInLayoutOrder.reduce(0, { $0 + (($1 as? ScrollView)?.contentSize.height ?? 0) })

    #if os(tvOS)
      let multipleComponents = subviewsInLayoutOrder.count > 1
      // To avoid conflicting accelerated scrolling behavior, if there is only one component in the
      // view hierarchy, then the content size will be the same as the frames height. A single component
      // is scrollable and will be used for accelerated scrolling.
      let height = multipleComponents
        ? computedHeight
        : frame.size.height
    #else
      let minimumContentHeight = bounds.height - (contentInset.top + contentInset.bottom)
      let height = fmax(computedHeight, minimumContentHeight)
    #endif

    contentSize = CGSize(width: bounds.size.width, height: height)
  }

  /// A custom implementation of layoutSubviews that handles the scrolling of all the underlaying views within the container.
  /// It does this by iterating over subviewsInLayoutOrder and sets the current offset for each individual view within the container.
  open override func layoutSubviews() {
    super.layoutSubviews()
    layoutViews()
    computeContentSize()
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
