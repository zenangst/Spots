@testable import Spots
import Foundation
import XCTest
import Fakery

class ListItemTests : XCTestCase {

  static let faker = Faker()
  let json: [String : AnyObject] = [
    "title" : ListItemTests.faker.name.firstName(),
    "subtitle" : ListItemTests.faker.name.lastName(),
    "image" : "smile",
    "type" : "person",
    "action" : "profile",
    "size" : ["width" : 88, "height" : 88],
    "meta" : ["contactInfo" : "555-Chewbacca"]
  ]

  func testInit() {
    // Test component created with JSON
    let jsonListItem = ListItem(json)
    XCTAssertEqual(jsonListItem.title,    json["title"] as? String)
    XCTAssertEqual(jsonListItem.subtitle, json["subtitle"] as? String)
    XCTAssertEqual(jsonListItem.image,    json["image"] as? String)
    XCTAssertEqual(jsonListItem.kind,     json["type"] as? String)
    XCTAssertEqual(jsonListItem.action,   json["action"] as? String)
    XCTAssert(jsonListItem.meta.count == 1)

    // Test component created programmatically
    let codeListItem = ListItem(
      title:    json["title"] as! String,
      subtitle: json["subtitle"] as! String,
      image:    json["image"] as! String,
      kind:     json["type"] as! String,
      action:   json["action"] as? String,
      size:     CGSize(
        width:  (json["size"] as! [String : AnyObject])["width"] as! CGFloat,
        height: (json["size"] as! [String : AnyObject])["height"] as! CGFloat
      ),
      meta:     json["meta"] as! [String : AnyObject]
    )

    XCTAssertEqual(codeListItem.title,    json["title"] as? String)
    XCTAssertEqual(codeListItem.subtitle, json["subtitle"] as? String)
    XCTAssertEqual(codeListItem.image,    json["image"] as? String)
    XCTAssertEqual(codeListItem.kind,     json["type"] as? String)
    XCTAssertEqual(codeListItem.action,   json["action"] as? String)
    XCTAssert(codeListItem.meta.count == 1)

    // Compare JSON and programmatically created component
    XCTAssert(jsonListItem == codeListItem)
    XCTAssertEqual(jsonListItem.meta["contactInfo"] as? String, codeListItem.meta["contactInfo"] as? String)
  }

}
