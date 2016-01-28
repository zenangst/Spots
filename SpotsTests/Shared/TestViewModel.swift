@testable import Spots
import Foundation
import XCTest
import Fakery

class ViewModelTests : XCTestCase {

  static let faker = Faker()
  let json: [String : AnyObject] = [
    "title" : ViewModelTests.faker.name.firstName(),
    "subtitle" : ViewModelTests.faker.name.lastName(),
    "image" : "smile",
    "type" : "person",
    "action" : "profile",
    "size" : ["width" : 88, "height" : 88],
    "meta" : ["contactInfo" : "555-Chewbacca"]
  ]

  func testInit() {
    // Test component created with JSON
    let jsonViewModel = ViewModel(json)
    XCTAssertEqual(jsonViewModel.title,    json["title"] as? String)
    XCTAssertEqual(jsonViewModel.subtitle, json["subtitle"] as? String)
    XCTAssertEqual(jsonViewModel.image,    json["image"] as? String)
    XCTAssertEqual(jsonViewModel.kind,     json["type"] as? String)
    XCTAssertEqual(jsonViewModel.action,   json["action"] as? String)
    XCTAssert(jsonViewModel.meta.count == 1)

    // Test component created programmatically
    let codeViewModel = ViewModel(
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

    XCTAssertEqual(codeViewModel.title,    json["title"] as? String)
    XCTAssertEqual(codeViewModel.subtitle, json["subtitle"] as? String)
    XCTAssertEqual(codeViewModel.image,    json["image"] as? String)
    XCTAssertEqual(codeViewModel.kind,     json["type"] as? String)
    XCTAssertEqual(codeViewModel.action,   json["action"] as? String)
    XCTAssert(codeViewModel.meta.count == 1)

    // Compare JSON and programmatically created component
    XCTAssert(jsonViewModel == codeViewModel)
    XCTAssertEqual(jsonViewModel.meta["contactInfo"] as? String, codeViewModel.meta["contactInfo"] as? String)
  }

  func testRelations() {
    let modelFoo = ViewModel(title: "foo",
      relations: ["bar" : [
        ViewModel(title: "bar")
        ]])
    XCTAssert(modelFoo.relations["bar"]!.first!.title == "bar")
  }
}
