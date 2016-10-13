@testable import Spots
import Foundation
import XCTest
import Brick

class ComponentTests : XCTestCase {

  let json: [String : Any] = [
    "title" : "title1",
    "kind" : "list",
    "span" : 1.0,
    "meta" : ["foo" : "bar"],
    "items" : [["title" : "item1"]]
  ]

  func testInit() {
    // Test component created with JSON
    let jsonComponent = Component(json)
    XCTAssertEqual(jsonComponent.title, json["title"] as? String)
    XCTAssertEqual(jsonComponent.kind,  json["kind"] as? String)
    XCTAssertEqual(jsonComponent.span,  json["span"] as? Double)

    XCTAssert((jsonComponent.meta as NSDictionary).isEqual(json["meta"] as! NSDictionary))
    XCTAssert(jsonComponent.items.count == 1)

    XCTAssertEqual(jsonComponent.items.first?.title, "item1")

    // Test component created programmatically
    let codeComponent = Component(
      title: json["title"] as! String,
      kind: json["kind"] as! String,
      span: json["span"] as! Double,
      items: [Item(title: "item1")],
      meta: json["meta"] as! [String : String])

    XCTAssertEqual(codeComponent.title, json["title"] as? String)
    XCTAssertEqual(codeComponent.kind,  json["kind"] as? String)
    XCTAssertEqual(codeComponent.span,  json["span"] as? Double)

    XCTAssert((codeComponent.meta as NSDictionary).isEqual(json["meta"] as! NSDictionary))
    XCTAssert(codeComponent.items.count == 1)

    // Compare JSON and programmatically created component
    XCTAssert(jsonComponent == codeComponent)
  }

  func testEquatable() {
    let jsonComponent = Component(json)
    var codeComponent = Component(
      title: json["title"] as! String,
      kind: json["kind"] as! String,
      span: json["span"] as! Double,
      meta: json["meta"] as! [String : String])
    XCTAssertFalse(jsonComponent == codeComponent)

    codeComponent.items.append(Item(title: "item2"))
    XCTAssertFalse(jsonComponent == codeComponent)
  }

  func testComponentDictionary() {
    let jsonComponent = Component(json)

    XCTAssertEqual(jsonComponent.dictionary["title"] as? String, json["title"] as? String)
    XCTAssertEqual(jsonComponent.dictionary["kind"] as? String, json["kind"] as? String)
    XCTAssertEqual(jsonComponent.dictionary["span"] as? Double, json["span"] as? Double)

    XCTAssertEqual((jsonComponent.dictionary["items"] as! [[String : Any]])[0]["title"] as? String,
                   ((json["items"] as! [AnyObject])[0] as! [String : Any])["title"] as? String)
    XCTAssertEqual((jsonComponent.dictionary["items"] as! [[String : Any]]).count, (json["items"]! as AnyObject).count)
  }

  func testComponentDiffing() {
    let initialJSON: [String : Any] = [
      "components" : [
        ["kind" : "list",
          "items" : [
            ["title" : "First list item"]
          ]
        ],
        ["kind" : "list",
          "items" : [
            ["title" : "First list item"]
          ]
        ]
      ]
    ]

    let newJSON: [String : Any] = [
      "components" : [
        ["kind" : "list",
          "items" : [
            ["title" : "First list item 2"]
          ]
        ],
        ["kind" : "grid",
          "items" : [
            ["title" : "First list item"]
          ]
        ]
      ]
    ]

    let lhs: [Component] = Parser.parse(initialJSON)
    let rhs: [Component] = Parser.parse(newJSON)

    XCTAssertTrue(lhs.first?.diff(component: rhs.first!) == .items)
    XCTAssertTrue(lhs[1].diff(component: rhs[1]) == .kind)
  }
}
