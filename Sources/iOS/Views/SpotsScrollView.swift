import UIKit
import QuartzCore

public class SpotsScrollView: UIScrollView {

  let KVOContext = UnsafeMutablePointer<()>(nil)

  private var subviewsInLayoutOrder = [UIView?]()

  public var forceUpdate = false {
    didSet {
      if forceUpdate {
        setNeedsLayout()
        layoutSubviews()
      }
    }
  }

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

  lazy public var contentView: SpotsContentView = SpotsContentView().then { [unowned self] in
    $0.frame = self.frame
  }

  deinit {
    contentView.subviews.forEach { $0.removeFromSuperview() }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(contentView)
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func didAddSubviewToContainer(subview: UIView) {
    subview.autoresizingMask = [.None]

    subviewsInLayoutOrder.append(subview)

    if subview.superview == contentView && !(subview is UIScrollView) {
      subview.addObserver(self, forKeyPath: "frame", options: .Old, context: KVOContext)
      subview.addObserver(self, forKeyPath: "bounds", options: .Old, context: KVOContext)
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

    scrollView.addObserver(self, forKeyPath: "contentSize", options: .Old, context: KVOContext)

    setNeedsLayout()
  }

  public override func willRemoveSubview(subview: UIView) {
    if subview is UIScrollView {
      subview.removeObserver(self, forKeyPath: "contentSize", context: KVOContext)
    } else if subview.superview == contentView {
      subview.removeObserver(self, forKeyPath: "frame", context: KVOContext)
      subview.removeObserver(self, forKeyPath: "bounds", context: KVOContext)
    }

    if let index = subviewsInLayoutOrder.indexOf({ $0 == subview }) {
      subviewsInLayoutOrder.removeAtIndex(index)
    }

    setNeedsLayout()
  }

  public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if let change = change where context == KVOContext && keyPath == "contentSize" {
      if let scrollView = object as? UIScrollView {
        guard let change = change[NSKeyValueChangeOldKey] else { return }
        let oldContentSize = change.CGSizeValue()
        let newContentSize = scrollView.contentSize
        if !CGSizeEqualToSize(newContentSize, oldContentSize) {
          setNeedsLayout()
          layoutIfNeeded()
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

  public override func layoutSubviews() {
    super.layoutSubviews()

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

        if !(subview is UICollectionView) {
          frame.size.height = ceil(fmin(remainingBoundsHeight, remainingContentHeight))
        }

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

    if let superview = superview where self.height != superview.height {
      self.height = superview.height
    }

    guard forceUpdate || initialContentOffset != contentOffset else { return }

    if forceUpdate == true { forceUpdate = false }
    setNeedsLayout()
    layoutIfNeeded()
  }
}
