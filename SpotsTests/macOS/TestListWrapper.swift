@testable import Spots
import Foundation
import XCTest

// MARK: - Mocks

fileprivate class ViewMock: NSView, ViewStateDelegate {

  var viewState: ViewState?

  func viewStateDidChange(_ viewState: ViewState) {
    self.viewState = viewState
  }
}

// MARK: - Test case

class ListWrapperTests: XCTestCase {

  private var listWrapper: ListWrapper!
  private var view: ViewMock!

  override func setUp() {
    super.setUp()
    listWrapper = ListWrapper()
    view = ViewMock()
    listWrapper.wrappedView = view
  }

  func testIsHighlighted() {
    XCTAssertNil(view.viewState)

    listWrapper.isHighlighted = true
    XCTAssertEqual(view.viewState, .highlighted)

    listWrapper.isHighlighted = false
    XCTAssertEqual(view.viewState, .normal)
  }

  func testIsSelected() {
    XCTAssertNil(view.viewState)

    listWrapper.isSelected = true
    XCTAssertEqual(view.viewState, .selected)

    listWrapper.isSelected = false
    XCTAssertEqual(view.viewState, .normal)
  }
}
