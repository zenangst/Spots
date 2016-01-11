@testable import Spots
import Foundation
import XCTest

class SpotFactoryTests : XCTestCase {

  let json: [String : AnyObject] = [
    "title" : "title1",
    "type" : "merry-go-round",
    "span" : 1,
    "meta" : ["foo" : "bar"],
    "items" : [["title" : "item1"]]
  ]

  func testRegisterAndResolve() {
    SpotFactory.register("merry-go-round", spot: CarouselSpot.self)

    let component = Component(json)
    var spot = SpotFactory.resolve(component)

    XCTAssertTrue(spot.component == component)
    XCTAssertTrue(spot is CarouselSpot)

    SpotFactory.register("merry-go-round", spot: GridSpot.self)
    spot = SpotFactory.resolve(component)

    XCTAssertTrue(spot.component == component)
    XCTAssertTrue(spot is GridSpot)
  }

  func testDefaultResolve() {
    var newJson = json
    newJson["type"] = "weirdo"

    let component = Component(newJson)
    let spot = SpotFactory.resolve(component)

    XCTAssertTrue(spot.component == component)
    XCTAssertTrue(spot is GridSpot)
  }
}
