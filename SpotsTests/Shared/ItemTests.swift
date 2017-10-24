@testable import Spots
import XCTest

class ItemTests: XCTestCase {

  var data: [String : Any] = [
    "title": "A",
    "subtitle": "B",
    "text": "C",
    "image": "D",
    "kind": "E",
    "size": ["width": 320.0, "height": 240.0],
    "action": "F",
    "meta": [
      "domain": "I"
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
    data["relations"] = ["Items": [data, data, data]]
    item = Item(data)

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

    let item2: Item! = item
    XCTAssertTrue(item2 == item)

    item.relations["Items"]![2].title = "new"
    XCTAssertFalse(item2 == item)
  }

  func testItemResolveMeta() {
    XCTAssertEqual(item.meta("domain", ""), (data["meta"] as! [String : AnyObject])["domain"] as? String)
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
    data["relations"] = ["Items": [data, data]]
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

  func testCodableWithJSONModel() throws {
    let kind = "kind"

    Configuration.shared.register(
      presenter: Presenter<DefaultItemView, Model>(identifier: kind) { _,_,_ in return .zero }
    )

    let json: [String : Any] = [
      "title": "A",
      "kind": kind,
      "model": ["value": "Test"]
    ]
    let item = Item(json)
    let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
    let decoder = JSONDecoder()
    let decodedItem = try decoder.decode(Item.self, from: data)

    XCTAssertNotNil(decodedItem.model)
    XCTAssertTrue(item == decodedItem)

    Configuration.shared.presenters.removeValue(forKey: kind)
  }

  func testCodable() throws {
    let kind = "kind"

    Configuration.shared.register(
      presenter: Presenter<DefaultItemView, Model>(identifier: kind) { _,_,_ in return .zero }
    )

    let model = Model(value: "Test")

    let item = Item(
      identifier: 0,
      title: "Title",
      subtitle: "Subtitle",
      text: "Text",
      image: "Image",
      model: model,
      kind: kind,
      action: "action",
      size: CGSize(width: 10, height: 10),
      meta: ["key": "value"],
      relations: ["relation": [Item(self.data)]]
    )
    let encoder = JSONEncoder()
    let data = try encoder.encode(item)
    let decoder = JSONDecoder()
    let decodedItem = try decoder.decode(Item.self, from: data)

    XCTAssertNotNil(decodedItem.model)
    XCTAssertTrue(item == decodedItem)

    Configuration.shared.presenters.removeValue(forKey: kind)
  }
}

private struct Model: ItemModel, Equatable {
  let value: String

  static func ==(lhs: Model, rhs: Model) -> Bool {
    return lhs.value == rhs.value
  }
}
