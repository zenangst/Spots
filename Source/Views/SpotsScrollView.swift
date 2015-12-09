import UIKit
import QuartzCore

public class SpotsScrollView: UIScrollView {

  let KVOContext = UnsafeMutablePointer<()>()

  private var subviewsInLayoutOrder = [UIView?]()

  lazy public var contentView: SpotsContentView = { [unowned self] in
    let view = SpotsContentView(frame: self.frame)
    return view
    }()

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
    subview.translatesAutoresizingMaskIntoConstraints = false

    subviewsInLayoutOrder.append(subview)

    if let scrollView = subview as? UIScrollView where scrollView.superview == contentView {
      scrollView.scrollEnabled = false

      if let collectionView = scrollView as? UICollectionView,
        layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        where layout.scrollDirection == .Horizontal  {
          scrollView.scrollEnabled = true
      }

      scrollView.addObserver(self, forKeyPath: "contentSize", options: .Old, context: KVOContext)
    }

    setNeedsLayout()
  }

  public override func willRemoveSubview(subview: UIView) {
    if let scrollView = subview as? UIScrollView where scrollView.superview == contentView {
      scrollView.removeObserver(self, forKeyPath: "contentSize", context: KVOContext)
    }

    if let index = subviewsInLayoutOrder.indexOf({ $0 == subview }) {
      subviewsInLayoutOrder.removeAtIndex(index)
    }
    setNeedsLayout()
  }

  public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if let change = change where context == KVOContext {
      if let scrollView = object as? UIScrollView,
        oldContentSize = change[NSKeyValueChangeOldKey] as? CGSize {
          if scrollView.contentSize != oldContentSize {
            setNeedsLayout()
            layoutIfNeeded()
          }
      } else if let view = object as? UIView,
        oldContentSize = change[NSKeyValueChangeOldKey] as? CGRect {
          if view.frame != oldContentSize {
            setNeedsLayout()
            layoutIfNeeded()
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

        // TODO: Fix this properly...
        // This should also apply for UICollectionView but I haven't figured out a way to resize them properly without it going ape-shit over that the layout is incorrect.
        if subview is UITableView {
          let remainingBoundsHeight = fmax(CGRectGetMaxY(bounds) - CGRectGetMinY(frame), 0.0)
          let remainingContentHeight = fmax(scrollView.contentSize.height - contentOffset.y, 0.0)
          frame.size.height = ceil(fmin(remainingBoundsHeight, remainingContentHeight))
        }

        frame.size.width = ceil(contentView.frame.size.width)

        scrollView.frame = frame
        scrollView.contentOffset = contentOffset

        yOffsetOfCurrentSubview += scrollView.contentSize.height + scrollView.contentInset.top + scrollView.contentInset.bottom
      } else if let subview = subview {
        var frame = subview.frame
        frame.origin.y = yOffsetOfCurrentSubview
        frame.size.width = contentView.bounds.size.width
        subview.frame = frame

        yOffsetOfCurrentSubview += frame.size.height
      }
    }

    let minimumContentHeight = bounds.height - (contentInset.top + contentInset.bottom)
    let initialContentOffset = contentOffset
    contentSize = CGSize(width: bounds.size.width, height: fmax(yOffsetOfCurrentSubview, minimumContentHeight))

    if initialContentOffset != contentOffset {
      setNeedsLayout()
      layoutIfNeeded()
    }
  }
}
