@testable import Spots
import Foundation
import XCTest

// MARK: - Mocks

fileprivate class ViewMock: UIView, ViewStateDelegate {

  var viewState: ViewState?

  func viewStateDidChange(_ viewState: ViewState) {
    self.viewState = viewState
  }
}

// MARK: - Test case

class GridWrapperTests: XCTestCase {

  private var gridWrapper: GridWrapper!
  private var view: ViewMock!

  override func setUp() {
    super.setUp()
    gridWrapper = GridWrapper()
    view = ViewMock()
    gridWrapper.wrappedView = view
  }

  func testIsHighlighted() {
    XCTAssertNil(view.viewState)

    gridWrapper.isHighlighted = true
    XCTAssertEqual(view.viewState, .highlighted)

    gridWrapper.isHighlighted = false
    XCTAssertEqual(view.viewState, .normal)
  }

  func testIsSelected() {
    XCTAssertNil(view.viewState)

    gridWrapper.isSelected = true
    XCTAssertEqual(view.viewState, .selected)

    gridWrapper.isSelected = false
    XCTAssertEqual(view.viewState, .normal)
  }
}
