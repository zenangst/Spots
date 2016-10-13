@testable import Spots
import Foundation
import XCTest

class FactoryTests : XCTestCase {

  let json: [String : Any] = [
    "title" : "title1" as AnyObject,
    "kind" : "merry-go-round" as AnyObject,
    "span" : 1 as AnyObject,
    "meta" : ["foo" : "bar"],
    "items" : [["title" : "item1"]]
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
}
