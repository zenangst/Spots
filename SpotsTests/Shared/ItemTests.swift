@testable import Spots
import XCTest

class ItemTests: XCTestCase {
  private let jsonEncoder = JSONEncoder()
  private let jsonDecoder = JSONDecoder()

  var json: [String : Any] = [
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
    let data = try! jsonEncoder.encode(json: json)
    item = try! jsonDecoder.decode(Item.self, from: data)
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

  func testRelations() throws {
    json["relations"] = ["Items": [json, json, json]]
    let data = try jsonEncoder.encode(json: json)
    item = try jsonDecoder.decode(Item.self, from: data)

    XCTAssertEqual(item.relations["Items"]!.count, 3)
    XCTAssertEqual(item.relations["Items"]!.first!.title, json["title"] as? String)
    XCTAssertEqual(item.relations["Items"]!.first!.subtitle, json["subtitle"] as? String)
    XCTAssertEqual(item.relations["Items"]!.first!.image, json["image"] as? String)
    XCTAssertEqual(item.relations["Items"]!.first!.kind, json["kind"] as? String)
    XCTAssertEqual(item.relations["Items"]!.first!.action, json["action"] as? String)

    XCTAssertEqual(item.relations["Items"]!.last!.title, json["title"] as? String)
    XCTAssertEqual(item.relations["Items"]!.last!.subtitle, json["subtitle"] as? String)
    XCTAssertEqual(item.relations["Items"]!.last!.image, json["image"] as? String)
    XCTAssertEqual(item.relations["Items"]!.last!.kind, json["kind"] as? String)
    XCTAssertEqual(item.relations["Items"]!.last!.action, json["action"] as? String)

    let item2: Item! = item
    XCTAssertTrue(item2 == item)

    item.relations["Items"]![2].title = "new"
    XCTAssertFalse(item2 == item)
  }

  func testItemResolveMeta() {
    XCTAssertEqual(item.meta("domain", ""), (json["meta"] as! [String : AnyObject])["domain"] as? String)
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

  func testItemUpdate() {
    item.update(kind: "test")
    XCTAssertEqual(item.kind, "test")
  }

  func testEncodingModel() throws {
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
      relations: ["relation": [self.item]]
    )
    let encoder = JSONEncoder()
    let data = try encoder.encode(item)
    let decoder = JSONDecoder()
    let decodedItem = try decoder.decode(Item.self, from: data)

    XCTAssertNotNil(decodedItem.model)
    XCTAssertTrue(item == decodedItem)

    Configuration.shared.presenters.removeValue(forKey: kind)
  }

  func testEncoding() throws {
    let data = try jsonEncoder.encode(item)
    let decodedItem = try jsonDecoder.decode(Item.self, from: data)

    XCTAssertTrue(item == decodedItem)
  }
}

private struct Model: ItemModel, Equatable {
  let value: String

  static func ==(lhs: Model, rhs: Model) -> Bool {
    return lhs.value == rhs.value
  }
}
