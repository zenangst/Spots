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

    XCTAssertEqual(gridSpot.render().contentInset.top, CGFloat(layout.contentInset.top))
    XCTAssertEqual(gridSpot.render().contentInset.left, CGFloat(layout.contentInset.left))
    XCTAssertEqual(gridSpot.render().contentInset.bottom, CGFloat(layout.contentInset.bottom))
    XCTAssertEqual(gridSpot.render().contentInset.right, CGFloat(layout.contentInset.right))

    XCTAssertEqual(gridSpot.layout.sectionInset.top, CGFloat(layout.sectionInset.top))
    XCTAssertEqual(gridSpot.layout.sectionInset.left, CGFloat(layout.sectionInset.left))
    XCTAssertEqual(gridSpot.layout.sectionInset.bottom, CGFloat(layout.sectionInset.bottom))
    XCTAssertEqual(gridSpot.layout.sectionInset.right, CGFloat(layout.sectionInset.right))
  }
}
