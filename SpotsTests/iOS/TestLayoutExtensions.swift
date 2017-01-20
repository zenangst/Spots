@testable import Spots
import XCTest

class LayoutExtensionsTests: XCTestCase {

  let json: [String : Any] = [
    "item-spacing" : 8.0,
    "line-spacing" : 6.0,
    "content-inset" : [
      "top" : 1.0,
      "left" : 2.0,
      "bottom" : 3.0,
      "right" : 4.0
    ],
    "section-inset" : [
      "top" : 5.0,
      "left" : 6.0,
      "bottom" : 7.0,
      "right" : 8.0
    ]
  ]

  func testConfigureGridableSpot() {
    let gridSpot = GridSpot(component: Component(span: 1))
    let layout = Layout(json)

    layout.configure(spot: gridSpot)

    XCTAssertEqual(gridSpot.layout.minimumInteritemSpacing, CGFloat(layout.itemSpacing))
    XCTAssertEqual(gridSpot.layout.minimumLineSpacing, CGFloat(layout.lineSpacing))

    XCTAssertEqual(gridSpot.render().contentInset.top, CGFloat(layout.inset.top))
    XCTAssertEqual(gridSpot.render().contentInset.left, CGFloat(layout.inset.left))
    XCTAssertEqual(gridSpot.render().contentInset.bottom, CGFloat(layout.inset.bottom))
    XCTAssertEqual(gridSpot.render().contentInset.right, CGFloat(layout.inset.right))
  }

  func testConfigureListableSpot() {
    let listSpot = ListSpot(component: Component(span: 1))
    let layout = Layout(json)

    layout.configure(spot: listSpot)

    XCTAssertEqual(listSpot.render().contentInset.top, CGFloat(layout.inset.top))
    XCTAssertEqual(listSpot.render().contentInset.left, CGFloat(layout.inset.left))
    XCTAssertEqual(listSpot.render().contentInset.bottom, CGFloat(layout.inset.bottom))
    XCTAssertEqual(listSpot.render().contentInset.right, CGFloat(layout.inset.right))
  }
}
