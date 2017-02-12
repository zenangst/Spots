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
    Factory.register(kind: "merry-go-round", spot: CarouselSpot.self)

    let component = Component(json)
    var spot = Factory.resolve(component: component)

    XCTAssertTrue(spot.component == component)
    XCTAssertTrue(spot is CarouselSpot)

    Factory.register(kind: "merry-go-round", spot: GridSpot.self)
    spot = Factory.resolve(component: component)

    XCTAssertTrue(spot.component == component)
    XCTAssertTrue(spot is GridSpot)
  }

  func testDefaultResolve() {
    var newJson = json
    newJson["type"] = "weirdo" as AnyObject?

    let component = Component(newJson)
    let spot = Factory.resolve(component: component)

    XCTAssertTrue(spot.component == component)
    XCTAssertTrue(spot is GridSpot)
  }

  func testFactoryParsingComponents() {
    let initialComponents = [
      Component(
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

    let spots: [Spotable] = initialComponents.map {
      let spot = Factory.resolve(component: $0)
      spot.setup(CGSize(width: 100, height: 100))
      return spot
    }

    /// Validate factory process
    XCTAssertEqual(spots.count, 1)
    XCTAssert(spots.first is ListSpot)

    /// Test first item in the first component of the first spot
    XCTAssertEqual(spots.first!.component.kind, "list")
    XCTAssertEqual(spots.first!.component.items[0].title, "Fullname")
    XCTAssertEqual(spots.first!.component.items[0].subtitle, "Job title")
    XCTAssertEqual(spots.first!.component.items[0].kind, "image")
    XCTAssertEqual(spots.first!.component.items[0].size, CGSize(width: 100, height: 44))
  }
}
