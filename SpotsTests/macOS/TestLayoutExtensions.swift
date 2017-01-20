@testable import Spots
import XCTest

class LayoutExtensionsTests: XCTestCase {

  let json: [String : Any] = [
    "item-spacing" : 8.0,
    "line-spacing" : 6.0,
    "inset" : [
      "top" : 1.0,
      "left" : 2.0,
      "bottom" : 3.0,
      "right" : 4.0
    ]
  ]

  func testConfigureGridableSpot() {
    let gridSpot = GridSpot(component: Component(span: 1))
    let gridableLayout = gridSpot.layout as? FlowLayout
    let layout = Layout(json)

    layout.configure(spot: gridSpot)

    XCTAssertEqual(gridableLayout?.minimumInteritemSpacing, CGFloat(layout.itemSpacing))
    XCTAssertEqual(gridableLayout?.minimumLineSpacing, CGFloat(layout.lineSpacing))

    XCTAssertEqual(gridSpot.render().contentInsets.top, CGFloat(layout.inset.top))
    XCTAssertEqual(gridSpot.render().contentInsets.left, CGFloat(layout.inset.left))
    XCTAssertEqual(gridSpot.render().contentInsets.bottom, CGFloat(layout.inset.bottom))
    XCTAssertEqual(gridSpot.render().contentInsets.right, CGFloat(layout.inset.right))

    XCTAssertEqual(gridableLayout?.sectionInset.top, CGFloat(layout.inset.top))
    XCTAssertEqual(gridableLayout?.sectionInset.left, CGFloat(layout.inset.left))
    XCTAssertEqual(gridableLayout?.sectionInset.bottom, CGFloat(layout.inset.bottom))
    XCTAssertEqual(gridableLayout?.sectionInset.right, CGFloat(layout.inset.right))
  }

  func testConfigureListableSpot() {
    let listSpot = ListSpot(component: Component(span: 1))
    let layout = Layout(json)

    layout.configure(spot: listSpot)

    XCTAssertEqual(listSpot.render().contentInsets.top, CGFloat(layout.inset.top))
    XCTAssertEqual(listSpot.render().contentInsets.left, CGFloat(layout.inset.left))
    XCTAssertEqual(listSpot.render().contentInsets.bottom, CGFloat(layout.inset.bottom))
    XCTAssertEqual(listSpot.render().contentInsets.right, CGFloat(layout.inset.right))
  }
}
