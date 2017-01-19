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
    json[Component.Key.Header] = "header"
    json[Component.Key.Identifier] =  "identifier"
    json[Component.Key.Index] = "index"
    json[Component.Key.Items] = "items"
    json[Component.Key.Kind] = "kind"
    json[Component.Key.Meta] = "meta"
    json[Component.Key.Span] = "span"
    json[Component.Key.Size] = "size"
    json[Component.Key.Height] = "height"
    json[Component.Key.Width] = "width"

    /// Compare creating a normal dictionary with a dictionary created with component keys.
    XCTAssertTrue((expected as NSDictionary).isEqual(to: json))

    /// Test subscripting with Component.Key
    XCTAssertEqual(json[Component.Key.Header] as! String, "header")
    XCTAssertEqual(json[Component.Key.Identifier] as! String, "identifier")
    XCTAssertEqual(json[Component.Key.Index] as! String, "index")
    XCTAssertEqual(json[Component.Key.Items] as! String, "items")
    XCTAssertEqual(json[Component.Key.Kind] as! String, "kind")
    XCTAssertEqual(json[Component.Key.Meta] as! String, "meta")
    XCTAssertEqual(json[Component.Key.Span] as! String, "span")
    XCTAssertEqual(json[Component.Key.Size] as! String, "size")
    XCTAssertEqual(json[Component.Key.Height] as! String, "height")
    XCTAssertEqual(json[Component.Key.Width] as! String, "width")

    /// Test lookup using property function with component key
    XCTAssertEqual(json.property(Component.Key.Header), "header")
    XCTAssertEqual(json.property(Component.Key.Identifier), "identifier")
    XCTAssertEqual(json.property(Component.Key.Index), "index")
    XCTAssertEqual(json.property(Component.Key.Items), "items")
    XCTAssertEqual(json.property(Component.Key.Kind), "kind")
    XCTAssertEqual(json.property(Component.Key.Meta), "meta")
    XCTAssertEqual(json.property(Component.Key.Span), "span")
    XCTAssertEqual(json.property(Component.Key.Size), "size")
    XCTAssertEqual(json.property(Component.Key.Height), "height")
    XCTAssertEqual(json.property(Component.Key.Width), "width")
  }
}
