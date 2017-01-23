@testable import Spots
import XCTest

class LayoutTests: XCTestCase {

  let json: [String : Any] = [
    "span" : 4.0,
    "item-spacing" : 8.0,
    "line-spacing" : 6.0,
    "dynamic-height" : true,
    "dynamic-span" : true,
    "inset" : [
      "top" : 1.0,
      "left" : 2.0,
      "bottom" : 3.0,
      "right" : 4.0
    ]
  ]

  func testDefaultValues() {
    let layout = Layout()

    XCTAssertEqual(layout.span, 0.0)
    XCTAssertEqual(layout.itemSpacing, 0.0)
    XCTAssertEqual(layout.lineSpacing, 0.0)
    XCTAssertEqual(layout.dynamicSpan, false)
    XCTAssertEqual(layout.dynamicHeight, true)
    XCTAssertEqual(layout.inset, Inset())
  }

  func testRegularInit() {
    let layout = Layout(span: 2.0, dynamicSpan: true, dynamicHeight: true, itemSpacing: 20.0, lineSpacing: 20.0, inset: Inset(top: 10.0))

    XCTAssertEqual(layout.span, 2.0)
    XCTAssertEqual(layout.itemSpacing, 20.0)
    XCTAssertEqual(layout.lineSpacing, 20.0)
    XCTAssertEqual(layout.dynamicSpan, true)
    XCTAssertEqual(layout.dynamicHeight, true)
    XCTAssertEqual(layout.inset, Inset(top: 10.0))
  }

  func testJSONMapping() {
    let layout = Layout(json)

    XCTAssertEqual(layout.span, 4.0)
    XCTAssertEqual(layout.itemSpacing, 8.0)
    XCTAssertEqual(layout.lineSpacing, 6.0)
    XCTAssertEqual(layout.dynamicSpan, true)
    XCTAssertEqual(layout.dynamicHeight, true)
    XCTAssertEqual(layout.inset, Inset(top: 1, left: 2, bottom: 3, right: 4))
  }

  func testLegacyJSONMapping() {
    let layout = Layout(json)

    XCTAssertEqual(layout.span, 4.0)
    XCTAssertEqual(layout.itemSpacing, 8.0)
    XCTAssertEqual(layout.lineSpacing, 6.0)
    XCTAssertEqual(layout.dynamicSpan, true)
    XCTAssertEqual(layout.dynamicHeight, true)
    XCTAssertEqual(layout.inset, Inset(top: 1, left: 2, bottom: 3, right: 4))
  }

  func testDictionary() {
    let layout = Layout(json)
    let layoutJSON = layout.dictionary

    XCTAssertEqual(layoutJSON["span"] as? Double, layout.span)
    XCTAssertEqual(layoutJSON["item-spacing"] as? Double, layout.itemSpacing)
    XCTAssertEqual(layoutJSON["line-spacing"] as? Double, layout.lineSpacing)
    XCTAssertEqual(layoutJSON["dynamic-span"] as? Bool, layout.dynamicSpan)
    XCTAssertEqual(layoutJSON["dynamic-height"] as? Bool, layout.dynamicHeight)
    XCTAssertEqual((layoutJSON["inset"] as? [String : Double])?["top"], layout.inset.top)
    XCTAssertEqual((layoutJSON["inset"] as? [String : Double])?["left"], layout.inset.left)
    XCTAssertEqual((layoutJSON["inset"] as? [String : Double])?["bottom"], layout.inset.bottom)
    XCTAssertEqual((layoutJSON["inset"] as? [String : Double])?["right"], layout.inset.right)
  }

  func testConfigureWithJSON() {
    var layout = Layout([:])

    XCTAssertNotEqual(layout.span, 4.0)
    XCTAssertNotEqual(layout.itemSpacing, 8.0)
    XCTAssertNotEqual(layout.lineSpacing, 6.0)
    XCTAssertNotEqual(layout.dynamicSpan, true)
    XCTAssertNotEqual(layout.dynamicHeight, false)
    XCTAssertNotEqual(layout.inset, Inset(top: 1, left: 2, bottom: 3, right: 4))

    layout.configure(withJSON: json)

    XCTAssertEqual(layout.span, 4.0)
    XCTAssertEqual(layout.itemSpacing, 8.0)
    XCTAssertEqual(layout.lineSpacing, 6.0)
    XCTAssertEqual(layout.dynamicSpan, true)
    XCTAssertEqual(layout.dynamicHeight, true)
    XCTAssertEqual(layout.inset, Inset(top: 1, left: 2, bottom: 3, right: 4))

    layout.configure(withJSON: [:])
    XCTAssertEqual(layout.span, 4.0)
    XCTAssertEqual(layout.itemSpacing, 8.0)
    XCTAssertEqual(layout.lineSpacing, 6.0)
    XCTAssertEqual(layout.dynamicSpan, true)
    XCTAssertEqual(layout.dynamicHeight, true)
    XCTAssertEqual(layout.inset, Inset(top: 0, left: 0, bottom: 0, right: 0))
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
