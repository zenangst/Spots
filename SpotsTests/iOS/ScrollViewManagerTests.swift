@testable import Spots
import Foundation
import XCTest

class ScrollViewMock: UIScrollView {
  var mockedIsTracking: Bool = true
  var mockedIsDragging: Bool = true
  var mockedIsDecelerating: Bool = true

  override var isTracking: Bool { return mockedIsTracking }
  override var isDragging: Bool { return mockedIsDragging }
  override var isDecelerating: Bool { return mockedIsDecelerating }
}

private extension ScrollView {
  func scrollTo(x: CGFloat = 0.0, y: CGFloat = 0.0) {
    setContentOffset(.init(x: x, y: y), animated: false)
    layoutSubviews()
  }
}

class ScrollViewManagerTests: XCTestCase {

  func testConstraintedView() {
    let scrollViewManager = ScrollViewManager()
    let frame = CGRect(origin: .zero, size: CGSize(width: 100, height: 800))
    let parentView = UIView(frame: frame)
    let spotsScrollView = SpotsScrollView(frame: frame)
    let scrollView = ScrollViewMock(frame: .zero)

    parentView.addSubview(spotsScrollView)
    scrollView.contentSize = CGSize(width: 300, height: 200)
    spotsScrollView.componentsView.addSubview(scrollView)

    // Check that no y constraint is applied because the view is fully
    // visible.
    spotsScrollView.scrollTo(y: 0)
    XCTAssertEqual(scrollView.frame.size, CGSize(width: 100, height: 200))
    scrollView.scrollTo(x: 100, y: 100)
    XCTAssertEqual(scrollView.contentOffset, .init(x: 100, y: 100))
    scrollViewManager.constrainScrollViewYOffset(scrollView, parentScrollView: spotsScrollView)
    XCTAssertEqual(scrollView.contentOffset, .init(x: 100, y: 100))

    // Scroll past so that ScrollViewManager will apply y constraint.
    spotsScrollView.scrollTo(y: 100)
    XCTAssertEqual(scrollView.frame.size, CGSize(width: 100, height: 100))
    scrollView.scrollTo(x: 100, y: 200)
    scrollViewManager.constrainScrollViewYOffset(scrollView, parentScrollView: spotsScrollView)
    XCTAssertEqual(scrollView.contentOffset, .init(x: 100, y: 100))

    // ScrollViewManager should apply y constraint because the scroll view
    // exceeds the parent scroll view.
    scrollView.contentSize = CGSize(width: 300, height: 900)
    spotsScrollView.scrollTo(y: 0)
    XCTAssertEqual(scrollView.frame.size, .init(width: 100, height: 800))
    spotsScrollView.scrollTo(y: -900)
    scrollViewManager.constrainScrollViewYOffset(scrollView, parentScrollView: spotsScrollView)
    XCTAssertEqual(scrollView.contentOffset, .init(x: 100, y: 0))

    // Check that constraint is only applied when the user scrolls.
    scrollView.mockedIsDragging = false
    scrollView.mockedIsTracking = false
    scrollView.mockedIsDecelerating = false
    scrollView.scrollTo(y: 900)
    scrollViewManager.constrainScrollViewYOffset(scrollView, parentScrollView: spotsScrollView)
    XCTAssertEqual(scrollView.contentOffset, .init(x: 0, y: 900))

    // Check that constraint only applies to views inside a `SpotsScrollView`.
    scrollView.scrollTo(y: -900)
    scrollViewManager.constrainScrollViewYOffset(scrollView, parentScrollView: nil)
    XCTAssertEqual(scrollView.contentOffset, .init(x: 0, y: -900))
  }
}
