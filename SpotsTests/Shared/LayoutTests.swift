@testable import Spots
import XCTest

class LayoutTests: XCTestCase {
  private let jsonEncoder = JSONEncoder()
  private let jsonDecoder = JSONDecoder()

  let json: [String : Any] = [
    "span": 4.0,
    "item-spacing": 8.0,
    "line-spacing": 6.0,
    "dynamic-height": true,
    "dynamic-span": true,
    "inset": [
      "top": 1.0,
      "left": 2.0,
      "bottom": 3.0,
      "right": 4.0
    ],
    "header-mode": "sticky",
    "infinite-scrolling": true,
    "show-empty-component": true
  ]

  func testDefaultValues() {
    let layout = Layout()

    XCTAssertEqual(layout.span, 0.0)
    XCTAssertEqual(layout.itemsPerRow, 1)
    XCTAssertEqual(layout.itemSpacing, 0.0)
    XCTAssertEqual(layout.lineSpacing, 0.0)
    XCTAssertEqual(layout.dynamicSpan, false)
    XCTAssertEqual(layout.dynamicHeight, true)
    XCTAssertEqual(layout.inset, Inset())
    XCTAssertEqual(layout.headerMode, .default)
    XCTAssertEqual(layout.pageIndicatorPlacement, nil)
    XCTAssertEqual(layout.infiniteScrolling, false)
    XCTAssertEqual(layout.showEmptyComponent, false)
  }

  func testRegularInit() {
    let layout = Layout(span: 2.0,
                        dynamicSpan: true,
                        dynamicHeight: true,
                        itemSpacing: 20.0,
                        lineSpacing: 20.0,
                        inset: Inset(top: 10.0),
                        headerMode: .sticky,
                        showEmptyComponent: true,
                        infiniteScrolling: true)

    XCTAssertEqual(layout.span, 2.0)
    XCTAssertEqual(layout.itemSpacing, 20.0)
    XCTAssertEqual(layout.lineSpacing, 20.0)
    XCTAssertEqual(layout.dynamicSpan, true)
    XCTAssertEqual(layout.dynamicHeight, true)
    XCTAssertEqual(layout.headerMode, .sticky)
    XCTAssertEqual(layout.infiniteScrolling, true)
    XCTAssertEqual(layout.showEmptyComponent, true)
  }

  func testDecoding() throws {
    let data = try jsonEncoder.encode(json: json)
    let layout = try jsonDecoder.decode(Layout.self, from: data)

    XCTAssertEqual(layout.span, 4.0)
    XCTAssertEqual(layout.itemSpacing, 8.0)
    XCTAssertEqual(layout.lineSpacing, 6.0)
    XCTAssertEqual(layout.dynamicSpan, true)
    XCTAssertEqual(layout.dynamicHeight, true)
    XCTAssertEqual(layout.inset, Inset(top: 1, left: 2, bottom: 3, right: 4))
    XCTAssertEqual(layout.headerMode, .sticky)
    XCTAssertEqual(layout.infiniteScrolling, true)
    XCTAssertEqual(layout.showEmptyComponent, true)
  }

  func testEncoding() throws {
    let layout = Layout {
      $0.span = 4.0
      $0.itemSpacing = 8.0
      $0.lineSpacing = 6.0
      $0.dynamicSpan = true
      $0.dynamicHeight = true
      $0.inset = Inset(top: 1, left: 2, bottom: 3, right: 4)
    }

    let data = try jsonEncoder.encode(layout)
    let decodedLayout = try jsonDecoder.decode(Layout.self, from: data)

    XCTAssertTrue(layout == decodedLayout)
  }

  func testBlockConfiguration() {
    let layout = Layout {
      $0.span = 4.0
      $0.itemSpacing = 8.0
      $0.lineSpacing = 6.0
      $0.dynamicSpan = true
      $0.dynamicHeight = true
      $0.inset = Inset(top: 1, left: 2, bottom: 3, right: 4)
    }

    XCTAssertEqual(layout.span, 4.0)
    XCTAssertEqual(layout.itemSpacing, 8.0)
    XCTAssertEqual(layout.lineSpacing, 6.0)
    XCTAssertEqual(layout.dynamicSpan, true)
    XCTAssertEqual(layout.dynamicHeight, true)
    XCTAssertEqual(layout.inset, Inset(top: 1, left: 2, bottom: 3, right: 4))
  }
}
