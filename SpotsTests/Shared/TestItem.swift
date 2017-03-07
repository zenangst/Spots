@testable import Spots
import XCTest

class TestItem: XCTestCase {

  var data: [String : Any] = [
    "title": "A",
    "subtitle": "B",
    "text": "C",
    "image": "D",
    "kind": "E",
    "size": ["width": 320.0, "height": 240.0],
    "action": "F",
    "children": [
      "child 1": "G",
      "child 2": "H"
    ],
    "meta": [
      "domain": "I"
    ]
  ]
  var item: ContentModel!

  override func setUp() {
    item = ContentModel(data)
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
    data["relations"] = ["Items": [data, data, data]]
    item = ContentModel(data)

    XCTAssertEqual(item.relations["Items"]!.count, 3)
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

    let item2: ContentModel! = item
    XCTAssertTrue(item2 == item)

    item.relations["Items"]![2].title = "new"
    XCTAssertFalse(item2 == item)
  }

  func testItemResolveMeta() {
    XCTAssertEqual(item.meta("domain", ""), (data["meta"] as! [String : AnyObject])["domain"] as? String)
  }

  func testMetaDataCreatedFromObject() {
    var data: [String : Any] = ["id": 11, "name": "Name"]

    item = ContentModel(meta: Meta(data))

    XCTAssertEqual(item.meta("id", 0), data["id"] as? Int)
    XCTAssertEqual(item.meta("name", ""), data["name"] as? String)
  }

  func testMetaInstance() {
    var data: [String : Any] = ["id": 11, "name": "Name"]
    item = ContentModel(meta: Meta(data))
    let result: Meta = item.metaInstance()

    XCTAssertEqual(result.id, data["id"] as? Int)
    XCTAssertEqual(result.name, data["name"] as? String)
  }

  func testItemEquality() {
    var left = ContentModel(identifier: "foo".hashValue)
    var right = ContentModel(identifier: "foo".hashValue)

    XCTAssertTrue(left === right)

    left = ContentModel(identifier: "foo".hashValue)
    right = ContentModel(identifier: "bar".hashValue)

    XCTAssertFalse(left === right)

    left = ContentModel(title: "foo", size: CGSize(width: 40, height: 40))
    right = ContentModel(title: "foo", size: CGSize(width: 40, height: 40))

    XCTAssertTrue(left === right)

    left = ContentModel(title: "foo", size: CGSize(width: 40, height: 40))
    right = ContentModel(title: "foo", size: CGSize(width: 60, height: 60))

    XCTAssertFalse(left === right)
  }

  func testItemCollectionEquality() {
    var left = [
      ContentModel(title: "foo", size: CGSize(width: 40, height: 40)),
      ContentModel(title: "foo", size: CGSize(width: 40, height: 40))
    ]
    var right = [
      ContentModel(title: "foo", size: CGSize(width: 40, height: 40)),
      ContentModel(title: "foo", size: CGSize(width: 40, height: 40))
    ]

    XCTAssertTrue(left === right)

    left = [
      ContentModel(title: "foo", size: CGSize(width: 40, height: 40)),
      ContentModel(title: "foo", size: CGSize(width: 60, height: 40))
    ]
    right = [
      ContentModel(title: "foo", size: CGSize(width: 40, height: 40)),
      ContentModel(title: "foo", size: CGSize(width: 40, height: 40))
    ]

    XCTAssertFalse(left === right)
  }

  func testItemDictionary() {
    data["relations"] = ["Items": [data, data]]
    item = ContentModel(data)

    let newItem: ContentModel! = ContentModel(item.dictionary)

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
    let sameItem = ContentModel(data)
    var newData: [String : Any] = data
    newData["children"] = [["child 1": "Anna"]]
    let otherItem = ContentModel(newData)

    XCTAssertTrue(item === sameItem)
    XCTAssertFalse(item === otherItem)

    data["relations"] = ["Items": [data, data, data]]

    item = ContentModel(data)
    var item2 = ContentModel(data)
    XCTAssertTrue(compareRelations(item, item2))

    item2.relations["Items"]![2].title = "new"
    XCTAssertFalse(compareRelations(item, item2))

    data["relations"] = ["Items": [data, data]]
    item2 = ContentModel(data)
    XCTAssertFalse(compareRelations(item, item2))
  }
}
