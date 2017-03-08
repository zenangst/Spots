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

  func testConfigureGridableComponent() {
    let gridComponent = GridComponent(model: ComponentModel(span: 1))
    let layout = Layout(json)

    layout.configure(component: gridComponent)

    XCTAssertEqual(gridComponent.layout.minimumInteritemSpacing, CGFloat(layout.itemSpacing))
    XCTAssertEqual(gridComponent.layout.minimumLineSpacing, CGFloat(layout.lineSpacing))

    XCTAssertEqual(gridComponent.view.contentInset.top, CGFloat(layout.inset.top))
    XCTAssertEqual(gridComponent.view.contentInset.left, CGFloat(layout.inset.left))
    XCTAssertEqual(gridComponent.view.contentInset.bottom, CGFloat(layout.inset.bottom))
    XCTAssertEqual(gridComponent.view.contentInset.right, CGFloat(layout.inset.right))
  }

  func testConfigureListableComponent() {
    let listComponent = ListComponent(model: ComponentModel(span: 1))
    let layout = Layout(json)

    layout.configure(component: listComponent)

    XCTAssertEqual(listComponent.view.contentInset.top, CGFloat(layout.inset.top))
    XCTAssertEqual(listComponent.view.contentInset.left, CGFloat(layout.inset.left))
    XCTAssertEqual(listComponent.view.contentInset.bottom, CGFloat(layout.inset.bottom))
    XCTAssertEqual(listComponent.view.contentInset.right, CGFloat(layout.inset.right))
  }
}
