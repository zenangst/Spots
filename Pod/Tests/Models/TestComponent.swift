import Foundation
import XCTest

class ComponentTests : XCTestCase {

  let json: [String : AnyObject] = [
    "title" : "title1",
    "type" : "list",
    "span" : 1,
    "meta" : ["foo" : "bar"],
    "items" : [["title" : "item1"]]
  ]

  func testInit() {
    // Test component created with JSON
    let jsonComponent = Component(json)
    XCTAssertEqual(jsonComponent.title, json["title"] as? String)
    XCTAssertEqual(jsonComponent.kind,  json["type"] as? String)
    XCTAssertEqual(jsonComponent.span,  json["span"] as? CGFloat)
    XCTAssertEqual(jsonComponent.meta,  json["meta"] as! [String : String])
    XCTAssert(jsonComponent.items.count == 1)
    XCTAssertEqual(jsonComponent.items.first?.title, "item1")

    // Test component created programmatically
    let codeComponent = Component(
      title: json["title"] as! String,
      kind: json["type"] as! String,
      span: json["span"] as! CGFloat,
      meta: json["meta"] as! [String : String],
      items: [ListItem(title: "item1")])
      
    XCTAssertEqual(codeComponent.title, json["title"] as? String)
    XCTAssertEqual(codeComponent.kind,  json["type"] as? String)
    XCTAssertEqual(codeComponent.span,  json["span"] as? CGFloat)
    XCTAssertEqual(codeComponent.meta,  json["meta"] as! [String : String])
    XCTAssert(codeComponent.items.count == 1)

    // Compare JSON and programmatically created component
    XCTAssert(jsonComponent == codeComponent)
  }
  
  func testEquatable() {
    let jsonComponent = Component(json)
    var codeComponent = Component(
      title: json["title"] as! String,
      kind: json["type"] as! String,
      span: json["span"] as! CGFloat,
      meta: json["meta"] as! [String : String])
    XCTAssertFalse(jsonComponent == codeComponent)

    codeComponent.items.append(ListItem(title: "item2"))
    XCTAssertFalse(jsonComponent == codeComponent)
  }

  func testInfixOperator() {
    var component = Component()
    let listItem = ListItem(title: "item1")

    component + listItem
    
    XCTAssert(component.items.count == 1)

    let listItems = [
      ListItem(title: "item2"),
      ListItem(title: "item3")
    ]

    component + listItems

    XCTAssert(component.items.count == 3)
    XCTAssert(component.items[1] == listItems[0])
    XCTAssert(component.items[2] == listItems[1])
  }
}
