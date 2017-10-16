@testable import Spots
import XCTest

class InsetiOSTests: XCTestCase {
  func testConfigureScrollView() {
    let inset = Inset(padding: 10)
    let scrollView = UIScrollView()
    let expectedInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

    inset.configure(scrollView: scrollView)
    XCTAssertEqual(scrollView.contentInset,
                   expectedInsets)
  }
}
