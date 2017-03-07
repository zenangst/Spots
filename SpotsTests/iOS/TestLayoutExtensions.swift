@testable import Spots
import XCTest

class LayoutExtensionsTests: XCTestCase {

  let json: [String : Any] = [
    "item-spacing": 8.0,
    "line-spacing": 6.0,
    "content-inset": [
      "top": 1.0,
      "left": 2.0,
      "bottom": 3.0,
      "right": 4.0
    ],
    "section-inset": [
      "top": 5.0,
      "left": 6.0,
      "bottom": 7.0,
      "right": 8.0
    ]
  ]

  func testConfigureGridableSpot() {
    let gridSpot = GridSpot(model: ComponentModel(span: 1))
    let layout = Layout(json)

    layout.configure(spot: gridSpot)

    XCTAssertEqual(gridSpot.layout.minimumInteritemSpacing, CGFloat(layout.itemSpacing))
    XCTAssertEqual(gridSpot.layout.minimumLineSpacing, CGFloat(layout.lineSpacing))

    XCTAssertEqual(gridSpot.view.contentInset.top, CGFloat(layout.inset.top))
    XCTAssertEqual(gridSpot.view.contentInset.left, CGFloat(layout.inset.left))
    XCTAssertEqual(gridSpot.view.contentInset.bottom, CGFloat(layout.inset.bottom))
    XCTAssertEqual(gridSpot.view.contentInset.right, CGFloat(layout.inset.right))
  }

  func testConfigureListableSpot() {
    let listSpot = ListSpot(model: ComponentModel(span: 1))
    let layout = Layout(json)

    layout.configure(spot: listSpot)

    XCTAssertEqual(listSpot.view.contentInset.top, CGFloat(layout.inset.top))
    XCTAssertEqual(listSpot.view.contentInset.left, CGFloat(layout.inset.left))
    XCTAssertEqual(listSpot.view.contentInset.bottom, CGFloat(layout.inset.bottom))
    XCTAssertEqual(listSpot.view.contentInset.right, CGFloat(layout.inset.right))
  }
}
