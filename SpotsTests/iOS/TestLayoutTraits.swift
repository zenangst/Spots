@testable import Spots
import XCTest

class LayoutTraitTests: XCTestCase {

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
    let layoutTrait = LayoutTrait()

    XCTAssertEqual(layoutTrait.span, 0.0)
    XCTAssertEqual(layoutTrait.itemSpacing, 0.0)
    XCTAssertEqual(layoutTrait.lineSpacing, 0.0)
    XCTAssertEqual(layoutTrait.dynamicSpan, false)
    XCTAssertEqual(layoutTrait.contentInset, ContentInset())
    XCTAssertEqual(layoutTrait.sectionInset, SectionInset())
  }

  func testJSONMapping() {
    let layoutTrait = LayoutTrait(json)

    XCTAssertEqual(layoutTrait.span, 4.0)
    XCTAssertEqual(layoutTrait.itemSpacing, 8.0)
    XCTAssertEqual(layoutTrait.lineSpacing, 6.0)
    XCTAssertEqual(layoutTrait.dynamicSpan, true)
    XCTAssertEqual(layoutTrait.contentInset, ContentInset(top: 1, left: 2, bottom: 3, right: 4))
    XCTAssertEqual(layoutTrait.sectionInset, SectionInset(top: 5, left: 6, bottom: 7, right: 8))
  }

  func testLegacyJSONMapping() {
    let layoutTrait = LayoutTrait(json)

    XCTAssertEqual(layoutTrait.span, 4.0)
    XCTAssertEqual(layoutTrait.itemSpacing, 8.0)
    XCTAssertEqual(layoutTrait.lineSpacing, 6.0)
    XCTAssertEqual(layoutTrait.dynamicSpan, true)
    XCTAssertEqual(layoutTrait.contentInset, ContentInset(top: 1, left: 2, bottom: 3, right: 4))
    XCTAssertEqual(layoutTrait.sectionInset, SectionInset(top: 5, left: 6, bottom: 7, right: 8))
  }

  func testLayoutTraitDictionaryConvertible() {
    let layoutTrait = LayoutTrait(json)
    let layoutJSON = layoutTrait.dictionary

    XCTAssertEqual(layoutJSON["span"] as? Double, layoutTrait.span)
    XCTAssertEqual(layoutJSON["item-spacing"] as? Double, layoutTrait.itemSpacing)
    XCTAssertEqual(layoutJSON["line-spacing"] as? Double, layoutTrait.lineSpacing)
    XCTAssertEqual(layoutJSON["dynamic-span"] as? Bool, layoutTrait.dynamicSpan)
    XCTAssertEqual((layoutJSON["content-inset"] as? [String : Double])?["top"], layoutTrait.contentInset.top)
    XCTAssertEqual((layoutJSON["content-inset"] as? [String : Double])?["left"], layoutTrait.contentInset.left)
    XCTAssertEqual((layoutJSON["content-inset"] as? [String : Double])?["bottom"], layoutTrait.contentInset.bottom)
    XCTAssertEqual((layoutJSON["content-inset"] as? [String : Double])?["right"], layoutTrait.contentInset.right)
    XCTAssertEqual((layoutJSON["section-inset"] as? [String : Double])?["top"], layoutTrait.sectionInset.top)
    XCTAssertEqual((layoutJSON["section-inset"] as? [String : Double])?["left"], layoutTrait.sectionInset.left)
    XCTAssertEqual((layoutJSON["section-inset"] as? [String : Double])?["bottom"], layoutTrait.sectionInset.bottom)
    XCTAssertEqual((layoutJSON["section-inset"] as? [String : Double])?["right"], layoutTrait.sectionInset.right)
  }

  func testLayoutTraitConfigureWithJSON() {
    var layoutTrait = LayoutTrait([:])

    XCTAssertNotEqual(layoutTrait.span, 4.0)
    XCTAssertNotEqual(layoutTrait.itemSpacing, 8.0)
    XCTAssertNotEqual(layoutTrait.lineSpacing, 6.0)
    XCTAssertNotEqual(layoutTrait.dynamicSpan, true)
    XCTAssertNotEqual(layoutTrait.contentInset, ContentInset(top: 1, left: 2, bottom: 3, right: 4))
    XCTAssertNotEqual(layoutTrait.sectionInset, SectionInset(top: 5, left: 6, bottom: 7, right: 8))

    layoutTrait.configure(withJSON: json)

    XCTAssertEqual(layoutTrait.span, 4.0)
    XCTAssertEqual(layoutTrait.itemSpacing, 8.0)
    XCTAssertEqual(layoutTrait.lineSpacing, 6.0)
    XCTAssertEqual(layoutTrait.dynamicSpan, true)
    XCTAssertEqual(layoutTrait.contentInset, ContentInset(top: 1, left: 2, bottom: 3, right: 4))
    XCTAssertEqual(layoutTrait.sectionInset, SectionInset(top: 5, left: 6, bottom: 7, right: 8))
  }

  func testLayoutTraitBlockConfiguration() {
    let layoutTrait = LayoutTrait {
      $0.span = 4.0
      $0.itemSpacing = 8.0
      $0.lineSpacing = 6.0
      $0.dynamicSpan = true
      $0.contentInset = ContentInset(top: 1, left: 2, bottom: 3, right: 4)
      $0.sectionInset = SectionInset(top: 5, left: 6, bottom: 7, right: 8)
    }

    XCTAssertEqual(layoutTrait.span, 4.0)
    XCTAssertEqual(layoutTrait.itemSpacing, 8.0)
    XCTAssertEqual(layoutTrait.lineSpacing, 6.0)
    XCTAssertEqual(layoutTrait.dynamicSpan, true)
    XCTAssertEqual(layoutTrait.contentInset, ContentInset(top: 1, left: 2, bottom: 3, right: 4))
    XCTAssertEqual(layoutTrait.sectionInset, SectionInset(top: 5, left: 6, bottom: 7, right: 8))
  }
}
