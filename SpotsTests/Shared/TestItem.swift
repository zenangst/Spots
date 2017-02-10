@testable import Spots
import XCTest

class TestItem: XCTestCase {

  var data: [String : Any] = [
    "title": "A",
    "subtitle": "B",
    "text": "C",
    "image" : "D",
    "kind" : "E",
    "size" : ["width" : 320.0, "height" : 240.0],
    "action" : "F",
    "children" : [
      "child 1" : "G",
      "child 2" : "H"
    ],
    "meta" : [
      "domain" : "I"
    ]
  ]
  var item: Item!

  override func setUp() {
    item = Item(data)
  }

  func testItemMapping() {
    XCTAssertEqual(item.title, "A")
    XCTAssertEqual(item.subtitle, "B")
    XCTAssertEqual(item.text, "C")
    XCTAssertEqual(item.image, "D")
    XCTAssertEqual(item.kind, "E")
    XCTAssertEqual(item.size.width, 320)
    XCTAssertEqual(item.size.height, 240)
    XCTAssertEqual(item.meta["domain"] as? String, "I")
  }

  func testRelations() {
    data["relations"] = ["Items" : [data, data, data]]
    item = Item(data)

    XCTAssertEqual(item.relations["Items"]!.count,3)
    XCTAssertEqual(item.relations["Items"]!.first!.title, data["title"] as? String)
    XCTAssertEqual(item.relations["Items"]!.first!.subtitle, data["subtitle"] as? String)
    XCTAssertEqual(item.relations["Items"]!.first!.image, data["image"] as? String)
    XCTAssertEqual(item.relations["Items"]!.first!.kind, data["kind"] as? String)
    XCTAssertEqual(item.relations["Items"]!.first!.action, data["action"] as? String)

    XCTAssertEqual(item.relations["Items"]!.last!.title, data["title"] as? String)
    XCTAssertEqual(item.relations["Items"]!.last!.subtitle, data["subtitle"] as? String)
    XCTAssertEqual(item.relations["Items"]!.last!.image, data["image"] as? String)
    XCTAssertEqual(item.relations["Items"]!.last!.kind, data["kind"] as? String)
    XCTAssertEqual(item.relations["Items"]!.last!.action, data["action"] as? String)

    let item2: Item! = item
    XCTAssertTrue(item2 == item)

    item.relations["Items"]![2].title = "new"
    XCTAssertFalse(item2 == item)
  }

  func testItemResolveMeta() {
    XCTAssertEqual(item.meta("domain", ""), (data["meta"] as! [String : AnyObject])["domain"] as? String)
  }

  func testMetaDataCreatedFromObject() {
    var data: [String : Any] = ["id": 11, "name": "Name"]

    item = Item(meta: Meta(data))

    XCTAssertEqual(item.meta("id", 0), data["id"] as? Int)
    XCTAssertEqual(item.meta("name", ""), data["name"] as? String)
  }

  func testMetaInstance() {
    var data: [String : Any] = ["id": 11, "name": "Name"]
    item = Item(meta: Meta(data))
    let result: Meta = item.metaInstance()

    XCTAssertEqual(result.id, data["id"] as? Int)
    XCTAssertEqual(result.name, data["name"] as? String)
  }

  func testItemEquality() {
    var left = Item(identifier: "foo".hashValue)
    var right = Item(identifier: "foo".hashValue)

    XCTAssertTrue(left === right)

    left = Item(identifier: "foo".hashValue)
    right = Item(identifier: "bar".hashValue)

    XCTAssertFalse(left === right)

    left = Item(title: "foo", size: CGSize(width: 40, height: 40))
    right = Item(title: "foo", size: CGSize(width: 40, height: 40))

    XCTAssertTrue(left === right)

    left = Item(title: "foo", size: CGSize(width: 40, height: 40))
    right = Item(title: "foo", size: CGSize(width: 60, height: 60))

    XCTAssertFalse(left === right)
  }

  func testItemCollectionEquality() {
    var left = [
      Item(title: "foo", size: CGSize(width: 40, height: 40)),
      Item(title: "foo", size: CGSize(width: 40, height: 40))
    ]
    var right = [
      Item(title: "foo", size: CGSize(width: 40, height: 40)),
      Item(title: "foo", size: CGSize(width: 40, height: 40))
    ]

    XCTAssertTrue(left === right)


    left = [
      Item(title: "foo", size: CGSize(width: 40, height: 40)),
      Item(title: "foo", size: CGSize(width: 60, height: 40))
    ]
    right = [
      Item(title: "foo", size: CGSize(width: 40, height: 40)),
      Item(title: "foo", size: CGSize(width: 40, height: 40))
    ]

    XCTAssertFalse(left === right)
  }

  func testItemDictionary() {
    data["relations"] = ["Items" : [data, data]]
    item = Item(data)

    let newItem: Item! = Item(item.dictionary)

    XCTAssertTrue(newItem == item)

    guard let firstRelation = item.relations["Items"]?.first,
      let lastRelation = item.relations["Items"]?.last
      else {
        XCTFail()
        return
    }

    XCTAssertEqual(newItem.relations["Items"]!.count, item.relations["Items"]!.count)
    XCTAssertTrue(newItem.relations["Items"]!.first! === firstRelation)
    XCTAssertTrue(newItem.relations["Items"]!.last! === lastRelation)
  }

  func testItemUpdate() {
    item.update(kind: "test")
    XCTAssertEqual(item.kind, "test")
  }

  func testCompareChildren() {
    let sameItem = Item(data)
    var newData: [String : Any] = data
    newData["children"] = [["child 1" : "Anna"]]
    let otherItem = Item(newData)

    XCTAssertTrue(item === sameItem)
    XCTAssertFalse(item === otherItem)

    data["relations"] = ["Items" : [data, data, data]]

    item = Item(data)
    var item2 = Item(data)
    XCTAssertTrue(compareRelations(item, item2))

    item2.relations["Items"]![2].title = "new"
    XCTAssertFalse(compareRelations(item, item2))

    data["relations"] = ["Items" : [data, data]]
    item2 = Item(data)
    XCTAssertFalse(compareRelations(item, item2))
  }
}
