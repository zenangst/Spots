@testable import Spots
import Foundation
import XCTest

class ComponentModelTests: XCTestCase {

  let json: [String : Any] = [
    "title": "title1",
    "kind": "list",
    "layout": [
      "span": 1.0
    ],
    "meta": ["foo": "bar"],
    "items": [["title": "item1"]]
  ]

  func testInit() {
    // Test component created with JSON
    let jsonComponentModel = ComponentModel(json)
    XCTAssertEqual(jsonComponentModel.title, json["title"] as? String)
    XCTAssertEqual(jsonComponentModel.kind, json["kind"] as? String)
    XCTAssertEqual(jsonComponentModel.layout?.span, (json["layout"] as? [String : Any])?["span"] as? Double)

    XCTAssert((jsonComponentModel.meta as NSDictionary).isEqual(json["meta"] as! NSDictionary))
    XCTAssert(jsonComponentModel.items.count == 1)

    XCTAssertEqual(jsonComponentModel.items.first?.title, "item1")

    let layout = Layout(json["layout"] as! [String : Any])
    let item = Item(title: "item1")

    // Test component created programmatically
    let codeComponentModel = ComponentModel(
      title: json["title"] as! String,
      kind: json["kind"] as! String,
      layout: layout,
      items: [item],
      meta: json["meta"] as! [String : String])

    XCTAssertEqual(codeComponentModel.title, json["title"] as? String)
    XCTAssertEqual(codeComponentModel.kind, json["kind"] as? String)
    XCTAssertEqual(codeComponentModel.layout?.span, (json["layout"] as? [String : Any])?["span"] as? Double)

    XCTAssert((codeComponentModel.meta as NSDictionary).isEqual(json["meta"] as! NSDictionary))
    XCTAssert(codeComponentModel.items.count == 1)

    // Compare JSON and programmatically created component
    XCTAssert(jsonComponentModel == codeComponentModel)
  }

  func testEquatable() {
    let jsonComponentModel = ComponentModel(json)
    var codeComponentModel = ComponentModel(
      title: json["title"] as! String,
      kind: json["kind"] as! String,
      span: (json["layout"] as? [String : Any])?["span"] as? Double,
      meta: json["meta"] as! [String : String])
    XCTAssertTrue(jsonComponentModel == codeComponentModel)

    codeComponentModel.items.append(Item(title: "item2"))
    XCTAssertTrue(jsonComponentModel == codeComponentModel)
  }

  func testComponentModelDictionary() {
    let jsonComponentModel = ComponentModel(json)

    XCTAssertEqual(jsonComponentModel.dictionary["title"] as? String, json["title"] as? String)
    XCTAssertEqual(jsonComponentModel.dictionary["kind"] as? String, json["kind"] as? String)
    XCTAssertEqual(jsonComponentModel.dictionary["span"] as? Double, json["span"] as? Double)

    XCTAssertEqual((jsonComponentModel.dictionary["items"] as! [[String : Any]])[0]["title"] as? String,
                   ((json["items"] as! [AnyObject])[0] as! [String : Any])["title"] as? String)
    XCTAssertEqual((jsonComponentModel.dictionary["items"] as! [[String : Any]]).count, (json["items"]! as AnyObject).count)
  }

  func testComponentModelDiffing() {
    let initialJSON: [String : Any] = [
      "components": [
        ["kind": "list",
          "items": [
            ["title": "First list item"]
          ]
        ],
        ["kind": "list",
          "items": [
            ["title": "First list item"]
          ]
        ]
      ]
    ]

    let newJSON: [String : Any] = [
      "components": [
        ["kind": "list",
          "items": [
            ["title": "First list item 2"]
          ]
        ],
        ["kind": "grid",
          "items": [
            ["title": "First list item"]
          ]
        ]
      ]
    ]

    let lhs: [ComponentModel] = Parser.parse(initialJSON)
    let rhs: [ComponentModel] = Parser.parse(newJSON)

    XCTAssertTrue(lhs.first?.diff(model: rhs.first!) == .items)
    XCTAssertTrue(lhs[1].diff(model: rhs[1]) == .kind)
  }

  func testComponentModelExtensions() {
    let expected: [String : Any] = [
      "header": "header",
      "identifier": "identifier",
      "index": "index",
      "items": "items",
      "kind": "kind",
      "meta": "meta",
      "span": "span",
      "size": "size",
      "height": "height",
      "width": "width"
    ]

    var json: [String : Any] = [:]
    json[ComponentModel.Key.header] = "header"
    json[ComponentModel.Key.identifier] =  "identifier"
    json[ComponentModel.Key.index] = "index"
    json[ComponentModel.Key.items] = "items"
    json[ComponentModel.Key.kind] = "kind"
    json[ComponentModel.Key.meta] = "meta"
    json[ComponentModel.Key.span] = "span"
    json[ComponentModel.Key.size] = "size"
    json[ComponentModel.Key.height] = "height"
    json[ComponentModel.Key.width] = "width"

    /// Compare creating a normal dictionary with a dictionary created with component keys.
    XCTAssertTrue((expected as NSDictionary).isEqual(to: json))

    /// Test subscripting with ComponentModel.Key
    XCTAssertEqual(json[ComponentModel.Key.header] as! String, "header")
    XCTAssertEqual(json[ComponentModel.Key.identifier] as! String, "identifier")
    XCTAssertEqual(json[ComponentModel.Key.index] as! String, "index")
    XCTAssertEqual(json[ComponentModel.Key.items] as! String, "items")
    XCTAssertEqual(json[ComponentModel.Key.kind] as! String, "kind")
    XCTAssertEqual(json[ComponentModel.Key.meta] as! String, "meta")
    XCTAssertEqual(json[ComponentModel.Key.span] as! String, "span")
    XCTAssertEqual(json[ComponentModel.Key.size] as! String, "size")
    XCTAssertEqual(json[ComponentModel.Key.height] as! String, "height")
    XCTAssertEqual(json[ComponentModel.Key.width] as! String, "width")

    /// Test lookup using property function with component key
    XCTAssertEqual(json.property(ComponentModel.Key.header), "header")
    XCTAssertEqual(json.property(ComponentModel.Key.identifier), "identifier")
    XCTAssertEqual(json.property(ComponentModel.Key.index), "index")
    XCTAssertEqual(json.property(ComponentModel.Key.items), "items")
    XCTAssertEqual(json.property(ComponentModel.Key.kind), "kind")
    XCTAssertEqual(json.property(ComponentModel.Key.meta), "meta")
    XCTAssertEqual(json.property(ComponentModel.Key.span), "span")
    XCTAssertEqual(json.property(ComponentModel.Key.size), "size")
    XCTAssertEqual(json.property(ComponentModel.Key.height), "height")
    XCTAssertEqual(json.property(ComponentModel.Key.width), "width")
  }

  func testComponentModelCompareWithHeadersAndFooters() {
    var lhs = ComponentModel(header: Item(title: "foo"), footer: Item(title: "foo"))
    var rhs = ComponentModel(header: Item(title: "foo"), footer: Item(title: "foo"))

    XCTAssertTrue(lhs == rhs)
    XCTAssertTrue(lhs === rhs)
    XCTAssertFalse(lhs != rhs)
    XCTAssertFalse(lhs !== rhs)
    XCTAssertEqual(lhs.diff(model: rhs), ComponentModelDiff.none)

    rhs.header = nil
    XCTAssertFalse(lhs == rhs)
    XCTAssertFalse(lhs === rhs)
    XCTAssertTrue(lhs != rhs)
    XCTAssertTrue(lhs !== rhs)
    XCTAssertEqual(lhs.diff(model: rhs), ComponentModelDiff.header)

    lhs.header = nil
    XCTAssertTrue(lhs == rhs)
    XCTAssertTrue(lhs === rhs)
    XCTAssertFalse(lhs != rhs)
    XCTAssertFalse(lhs !== rhs)
    XCTAssertEqual(lhs.diff(model: rhs), ComponentModelDiff.none)

    lhs = ComponentModel(header: Item(title: "bar"), footer: Item(title: "bar"))
    XCTAssertFalse(lhs == rhs)
    XCTAssertFalse(lhs === rhs)
    XCTAssertTrue(lhs != rhs)
    XCTAssertTrue(lhs !== rhs)
    XCTAssertEqual(lhs.diff(model: rhs), ComponentModelDiff.header)

    rhs = ComponentModel(header: Item(title: "foo"), footer: Item(title: "foo"))
    XCTAssertFalse(lhs == rhs)
    XCTAssertFalse(lhs === rhs)
    XCTAssertTrue(lhs != rhs)
    XCTAssertTrue(lhs !== rhs)
    XCTAssertEqual(lhs.diff(model: rhs), ComponentModelDiff.header)

    rhs = ComponentModel(header: Item(title: "bar"), footer: Item(title: "foo"))
    XCTAssertFalse(lhs == rhs)
    XCTAssertFalse(lhs === rhs)
    XCTAssertTrue(lhs != rhs)
    XCTAssertTrue(lhs !== rhs)
    XCTAssertEqual(lhs.diff(model: rhs), ComponentModelDiff.footer)
  }

  func testComponentModelCompareWithIdentifier() {
    let lhs = ComponentModel(identifier: "foo")
    var rhs = ComponentModel(identifier: "foo")

    XCTAssertEqual(lhs, rhs)
    XCTAssertEqual(lhs.diff(model: rhs), ComponentModelDiff.none)

    rhs.identifier = "bar"

    XCTAssertNotEqual(lhs, rhs)
    XCTAssertEqual(lhs.diff(model: rhs), ComponentModelDiff.identifier)
  }
}
