@testable import Spots
import XCTest

class LayoutTests: XCTestCase {

  let json: [String : Any] = [
    "span" : 4.0,
    "item-spacing" : 8.0,
    "line-spacing" : 6.0,
    "dynamic-span" : true,
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

  func testDefaultValues() {
    let layout = Layout()

    XCTAssertEqual(layout.span, 0.0)
    XCTAssertEqual(layout.itemSpacing, 0.0)
    XCTAssertEqual(layout.lineSpacing, 0.0)
    XCTAssertEqual(layout.dynamicSpan, false)
    XCTAssertEqual(layout.contentInset, ContentInset())
    XCTAssertEqual(layout.sectionInset, SectionInset())
  }

  func testJSONMapping() {
    let layout = Layout(json)

    XCTAssertEqual(layout.span, 4.0)
    XCTAssertEqual(layout.itemSpacing, 8.0)
    XCTAssertEqual(layout.lineSpacing, 6.0)
    XCTAssertEqual(layout.dynamicSpan, true)
    XCTAssertEqual(layout.contentInset, ContentInset(top: 1, left: 2, bottom: 3, right: 4))
    XCTAssertEqual(layout.sectionInset, SectionInset(top: 5, left: 6, bottom: 7, right: 8))
  }

  func testLegacyJSONMapping() {
    let layout = Layout(json)

    XCTAssertEqual(layout.span, 4.0)
    XCTAssertEqual(layout.itemSpacing, 8.0)
    XCTAssertEqual(layout.lineSpacing, 6.0)
    XCTAssertEqual(layout.dynamicSpan, true)
    XCTAssertEqual(layout.contentInset, ContentInset(top: 1, left: 2, bottom: 3, right: 4))
    XCTAssertEqual(layout.sectionInset, SectionInset(top: 5, left: 6, bottom: 7, right: 8))
  }

  func testLayoutDictionaryConvertible() {
    let layout = Layout(json)
    let layoutJSON = layout.dictionary

    XCTAssertEqual(layoutJSON["span"] as? Double, layout.span)
    XCTAssertEqual(layoutJSON["item-spacing"] as? Double, layout.itemSpacing)
    XCTAssertEqual(layoutJSON["line-spacing"] as? Double, layout.lineSpacing)
    XCTAssertEqual(layoutJSON["dynamic-span"] as? Bool, layout.dynamicSpan)
    XCTAssertEqual((layoutJSON["content-inset"] as? [String : Double])?["top"], layout.contentInset.top)
    XCTAssertEqual((layoutJSON["content-inset"] as? [String : Double])?["left"], layout.contentInset.left)
    XCTAssertEqual((layoutJSON["content-inset"] as? [String : Double])?["bottom"], layout.contentInset.bottom)
    XCTAssertEqual((layoutJSON["content-inset"] as? [String : Double])?["right"], layout.contentInset.right)
    XCTAssertEqual((layoutJSON["section-inset"] as? [String : Double])?["top"], layout.sectionInset.top)
    XCTAssertEqual((layoutJSON["section-inset"] as? [String : Double])?["left"], layout.sectionInset.left)
    XCTAssertEqual((layoutJSON["section-inset"] as? [String : Double])?["bottom"], layout.sectionInset.bottom)
    XCTAssertEqual((layoutJSON["section-inset"] as? [String : Double])?["right"], layout.sectionInset.right)
  }

  func testLayoutConfigureWithJSON() {
    var layout = Layout([:])

    XCTAssertNotEqual(layout.span, 4.0)
    XCTAssertNotEqual(layout.itemSpacing, 8.0)
    XCTAssertNotEqual(layout.lineSpacing, 6.0)
    XCTAssertNotEqual(layout.dynamicSpan, true)
    XCTAssertNotEqual(layout.contentInset, ContentInset(top: 1, left: 2, bottom: 3, right: 4))
    XCTAssertNotEqual(layout.sectionInset, SectionInset(top: 5, left: 6, bottom: 7, right: 8))

    layout.configure(withJSON: json)

    XCTAssertEqual(layout.span, 4.0)
    XCTAssertEqual(layout.itemSpacing, 8.0)
    XCTAssertEqual(layout.lineSpacing, 6.0)
    XCTAssertEqual(layout.dynamicSpan, true)
    XCTAssertEqual(layout.contentInset, ContentInset(top: 1, left: 2, bottom: 3, right: 4))
    XCTAssertEqual(layout.sectionInset, SectionInset(top: 5, left: 6, bottom: 7, right: 8))

    layout.configure(withJSON: [:])
    XCTAssertEqual(layout.span, 4.0)
    XCTAssertEqual(layout.itemSpacing, 8.0)
    XCTAssertEqual(layout.lineSpacing, 6.0)
    XCTAssertEqual(layout.dynamicSpan, true)
    XCTAssertEqual(layout.contentInset, ContentInset(top: 0, left: 0, bottom: 0, right: 0))
    XCTAssertEqual(layout.sectionInset, SectionInset(top: 0, left: 0, bottom: 0, right: 0))
  }

  func testLayoutBlockConfiguration() {
    let layout = Layout {
      $0.span = 4.0
      $0.itemSpacing = 8.0
      $0.lineSpacing = 6.0
      $0.dynamicSpan = true
      $0.contentInset = ContentInset(top: 1, left: 2, bottom: 3, right: 4)
      $0.sectionInset = SectionInset(top: 5, left: 6, bottom: 7, right: 8)
    }

    XCTAssertEqual(layout.span, 4.0)
    XCTAssertEqual(layout.itemSpacing, 8.0)
    XCTAssertEqual(layout.lineSpacing, 6.0)
    XCTAssertEqual(layout.dynamicSpan, true)
    XCTAssertEqual(layout.contentInset, ContentInset(top: 1, left: 2, bottom: 3, right: 4))
    XCTAssertEqual(layout.sectionInset, SectionInset(top: 5, left: 6, bottom: 7, right: 8))
  }
}
