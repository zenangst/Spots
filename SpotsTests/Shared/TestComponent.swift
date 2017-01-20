@testable import Spots
import Foundation
import XCTest
import Brick

class ComponentTests : XCTestCase {

  let json: [String : Any] = [
    "title" : "title1",
    "kind" : "list",
    "layout" : [
      "span" : 1.0
    ],
    "meta" : ["foo" : "bar"],
    "items" : [["title" : "item1"]]
  ]

  func testInit() {
    // Test component created with JSON
    let jsonComponent = Component(json)
    XCTAssertEqual(jsonComponent.title, json["title"] as? String)
    XCTAssertEqual(jsonComponent.kind,  json["kind"] as? String)
    XCTAssertEqual(jsonComponent.layout?.span,  (json["layout"] as? [String : Any])?["span"] as? Double)

    XCTAssert((jsonComponent.meta as NSDictionary).isEqual(json["meta"] as! NSDictionary))
    XCTAssert(jsonComponent.items.count == 1)

    XCTAssertEqual(jsonComponent.items.first?.title, "item1")

    let layout = Layout(json["layout"] as! [String : Any])
    let item = Item(title: "item1")

    // Test component created programmatically
    let codeComponent = Component(
      title: json["title"] as! String,
      kind: json["kind"] as! String,
      layout: layout,
      items: [item],
      meta: json["meta"] as! [String : String])

    XCTAssertEqual(codeComponent.title, json["title"] as? String)
    XCTAssertEqual(codeComponent.kind,  json["kind"] as? String)
    XCTAssertEqual(codeComponent.layout?.span,  (json["layout"] as? [String : Any])?["span"] as? Double)

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
      span: (json["layout"] as? [String : Any])?["span"] as? Double,
      meta: json["meta"] as! [String : String])
    XCTAssertTrue(jsonComponent == codeComponent)

    codeComponent.items.append(Item(title: "item2"))
    XCTAssertTrue(jsonComponent == codeComponent)
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

  func testComponentExtensions() {
    let expected: [String : Any] = [
      "header" : "header",
      "identifier" : "identifier",
      "index" : "index",
      "items" : "items",
      "kind" : "kind",
      "meta" : "meta",
      "span" : "span",
      "size" : "size",
      "height" : "height",
      "width" : "width"
    ]

    var json: [String : Any] = [:]
    json[Component.Key.header] = "header"
    json[Component.Key.identifier] =  "identifier"
    json[Component.Key.index] = "index"
    json[Component.Key.items] = "items"
    json[Component.Key.kind] = "kind"
    json[Component.Key.meta] = "meta"
    json[Component.Key.span] = "span"
    json[Component.Key.size] = "size"
    json[Component.Key.height] = "height"
    json[Component.Key.width] = "width"

    /// Compare creating a normal dictionary with a dictionary created with component keys.
    XCTAssertTrue((expected as NSDictionary).isEqual(to: json))

    /// Test subscripting with Component.Key
    XCTAssertEqual(json[Component.Key.header] as! String, "header")
    XCTAssertEqual(json[Component.Key.identifier] as! String, "identifier")
    XCTAssertEqual(json[Component.Key.index] as! String, "index")
    XCTAssertEqual(json[Component.Key.items] as! String, "items")
    XCTAssertEqual(json[Component.Key.kind] as! String, "kind")
    XCTAssertEqual(json[Component.Key.meta] as! String, "meta")
    XCTAssertEqual(json[Component.Key.span] as! String, "span")
    XCTAssertEqual(json[Component.Key.size] as! String, "size")
    XCTAssertEqual(json[Component.Key.height] as! String, "height")
    XCTAssertEqual(json[Component.Key.width] as! String, "width")

    /// Test lookup using property function with component key
    XCTAssertEqual(json.property(Component.Key.header), "header")
    XCTAssertEqual(json.property(Component.Key.identifier), "identifier")
    XCTAssertEqual(json.property(Component.Key.index), "index")
    XCTAssertEqual(json.property(Component.Key.items), "items")
    XCTAssertEqual(json.property(Component.Key.kind), "kind")
    XCTAssertEqual(json.property(Component.Key.meta), "meta")
    XCTAssertEqual(json.property(Component.Key.span), "span")
    XCTAssertEqual(json.property(Component.Key.size), "size")
    XCTAssertEqual(json.property(Component.Key.height), "height")
    XCTAssertEqual(json.property(Component.Key.width), "width")
  }
}
