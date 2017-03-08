@testable import Spots
import Foundation
import XCTest

class FactoryTests: XCTestCase {

  let json: [String : Any] = [
    "title": "title1",
    "kind": "merry-go-round",
    "span": 1.0,
    "meta": ["foo": "bar"],
    "items": [["title": "item1"]]
  ]

  func testRegisterAndResolve() {
    Factory.register(kind: "merry-go-round", component: CarouselComponent.self)

    let model = ComponentModel(json)
    var component = Factory.resolve(model: model)

    XCTAssertTrue(component.model == model)
    XCTAssertTrue(component is CarouselComponent)

    Factory.register(kind: "merry-go-round", component: GridComponent.self)
    component = Factory.resolve(model: model)

    XCTAssertTrue(component.model == model)
    XCTAssertTrue(component is GridComponent)
  }

  func testDefaultResolve() {
    var newJson = json
    newJson["type"] = "weirdo" as AnyObject?

    let model = ComponentModel(newJson)
    let component = Factory.resolve(model: model)

    XCTAssertTrue(component.model == model)
    XCTAssertTrue(component is GridComponent)
  }

  func testFactoryParsingComponentModels() {
    let initialComponentModels = [
      ComponentModel(
        kind: "list",
        span: 1.0,
        items: [
          Item(title: "Fullname", subtitle: "Job title", kind: "image"),
          Item(title: "Follow", kind: "toggle", meta: ["dynamic-height": true]),
          Item(title: "First name", subtitle: "Input first name", kind: "info"),
          Item(title: "Last name", subtitle: "Input last name", kind: "info"),
          Item(title: "Twitter", subtitle: "@twitter", kind: "info"),
          Item(title: "", subtitle: "Biography", kind: "core", meta: ["dynamic-height": true])
        ]
      )
    ]

    let components: [CoreComponent] = initialComponentModels.map {
      let component = Factory.resolve(model: $0)
      component.setup(CGSize(width: 100, height: 100))
      return component
    }

    /// Validate factory process
    XCTAssertEqual(components.count, 1)
    XCTAssert(components.first is ListComponent)

    /// Test first item in the first component of the first component
    XCTAssertEqual(components.first!.model.kind, "list")
    XCTAssertEqual(components.first!.model.items[0].title, "Fullname")
    XCTAssertEqual(components.first!.model.items[0].subtitle, "Job title")
    XCTAssertEqual(components.first!.model.items[0].kind, "image")
    XCTAssertEqual(components.first!.model.items[0].size, CGSize(width: 100, height: 44))
  }
}
