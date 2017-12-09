@testable import Spots
import Foundation
import XCTest

class ComponentModelTests: XCTestCase {
  struct Model: ComponentSubModel, Equatable {
    let version: String

    static func ==(lhs: Model, rhs: Model) -> Bool {
      return lhs.version == rhs.version
    }
  }

  private let jsonEncoder = JSONEncoder()
  private let jsonDecoder = JSONDecoder()

  let json: [String : Any] = [
    "kind": "list",
    "layout": [
      "span": 1.0
    ],
    "model" : [
      "version" : "2.0.1"
    ],
    "meta": ["foo": "bar"],
    "items": [["title": "item1"]]
  ]

  override func setUp() {
    Configuration.shared.registerComponentModel(Model.self)
  }

  func testInit() throws {
    // Test component created with JSON
    let jsonComponentModel: ComponentModel = try makeModel(from: json)
    XCTAssertEqual(jsonComponentModel.kind.rawValue, json["kind"] as? String)
    XCTAssertEqual(jsonComponentModel.layout.span, (json["layout"] as? [String : Any])?["span"] as? Double)

    XCTAssert((jsonComponentModel.meta as NSDictionary).isEqual(json["meta"] as! NSDictionary))
    XCTAssert(jsonComponentModel.items.count == 1)

    XCTAssertEqual(jsonComponentModel.items.first?.title, "item1")

    let layoutData = try jsonEncoder.encode(json: json["layout"] as! [String : Any])
    let layout = try jsonDecoder.decode(Layout.self, from: layoutData)
    let item = Item(title: "item1")

    // Test component created programmatically
    var codeComponentModel = ComponentModel(
      kind: ComponentKind(rawValue: json["kind"] as! String)!,
      layout: layout,
      items: [item],
      meta: json["meta"] as! [String : String])
    codeComponentModel.update(model: Model(version: "2.0.1"))

    XCTAssertEqual(codeComponentModel.kind.rawValue, json["kind"] as? String)
    XCTAssertEqual(codeComponentModel.layout.span, (json["layout"] as? [String : Any])?["span"] as? Double)

    XCTAssert((codeComponentModel.meta as NSDictionary).isEqual(json["meta"] as! NSDictionary))
    XCTAssert(codeComponentModel.items.count == 1)
    XCTAssert(codeComponentModel.resolveModel() == Model(version: "2.0.1"))

    // Compare JSON and programmatically created component
    XCTAssert(jsonComponentModel == codeComponentModel)
  }

  func testConfifugrationDefaultKind() {
    Configuration.shared.defaultComponentKind = .list
    let firstModel = ComponentModel()
    XCTAssertEqual(firstModel.kind, .list)

    Configuration.shared.defaultComponentKind = .grid
    let secondModel = ComponentModel()
    XCTAssertEqual(secondModel.kind, .grid)

    // Reset configuration to the default
    Configuration.shared.defaultComponentKind = .grid
  }

  func testEquatable() throws {
    let jsonComponentModel: ComponentModel = try makeModel(from: json)
    let layout: Layout = try makeModel(from: json["layout"] as! [String: Any])
    var codeComponentModel = ComponentModel(
      kind: ComponentKind(rawValue: json["kind"] as! String)!,
      layout: layout,
      meta: json["meta"] as! [String : String])
    XCTAssertTrue(jsonComponentModel == codeComponentModel)

    codeComponentModel.items.append(Item(title: "item2"))
    XCTAssertTrue(jsonComponentModel == codeComponentModel)
  }

  func testDecoding() throws {
    let json: [String: Any] = [
      "title": "title",
      "header": [
        "title" : "title",
        "subtitle" : "subtitle",
        "text" : "text",
        "kind" : "header-kind"
      ],
      "footer": [
        "title" : "title",
        "subtitle" : "subtitle",
        "text" : "text",
        "kind" : "footer-kind"
      ],
      "items" : [
        ["title" : "foo1"],
        ["title" : "foo2"],
        ["title" : "foo3"],
        ["title" : "foo4"],
        ["title" : "foo5"]
      ]
    ]

    let model: ComponentModel = try makeModel(from: json)

    XCTAssertEqual(model.header?.title, "title")
    XCTAssertEqual(model.header?.subtitle, "subtitle")
    XCTAssertEqual(model.header?.text, "text")
    XCTAssertEqual(model.header?.kind, "header-kind")

    XCTAssertEqual(model.footer?.title, "title")
    XCTAssertEqual(model.footer?.subtitle, "subtitle")
    XCTAssertEqual(model.footer?.text, "text")
    XCTAssertEqual(model.footer?.kind, "footer-kind")

    XCTAssertEqual(model.items.count, 5)
    XCTAssertEqual(model.items[0].title, "foo1")
    XCTAssertEqual(model.items[1].title, "foo2")
    XCTAssertEqual(model.items[2].title, "foo3")
    XCTAssertEqual(model.items[3].title, "foo4")
    XCTAssertEqual(model.items[4].title, "foo5")
  }

  func testEncoding() throws {
    let componentModel: ComponentModel = try makeModel(from: json)
    let data = try jsonEncoder.encode(componentModel)
    let decodedComponentModel = try jsonDecoder.decode(ComponentModel.self, from: data)

    XCTAssertTrue(componentModel == decodedComponentModel)
  }

  func testComponentModelDiffing() throws {
    let initialJSON: [String : Any] = [
      "components": [
        ["kind": "list",
          "items": [
            ["title": "First list item"]
          ]
        ],
        ["kind": "list",
          "items": [
            ["title": "First list item"]
          ]
        ]
      ]
    ]

    let newJSON: [String : Any] = [
      "components": [
        ["kind": "list",
          "items": [
            ["title": "First list item 2"]
          ]
        ],
        ["kind": "grid",
          "items": [
            ["title": "First list item"]
          ]
        ]
      ]
    ]

    // JSON
    var lhs: [ComponentModel] = Parser.parseComponentModels(json: initialJSON)
    var rhs: [ComponentModel] = Parser.parseComponentModels(json: newJSON)

    XCTAssertTrue(lhs.first?.diff(model: rhs.first!) == .items)
    XCTAssertTrue(lhs[1].diff(model: rhs[1]) == .kind)

    // Data
    let initialData = try jsonEncoder.encode(json: initialJSON)
    let newData = try jsonEncoder.encode(json: newJSON)

    lhs = Parser.parseComponentModels(data: initialData)
    rhs = Parser.parseComponentModels(data: newData)

    XCTAssertTrue(lhs.first?.diff(model: rhs.first!) == .items)
    XCTAssertTrue(lhs[1].diff(model: rhs[1]) == .kind)
  }

  func testComponentModelCompareWithHeadersAndFooters() {
    var lhs = ComponentModel(header: Item(title: "foo"), footer: Item(title: "foo"))
    var rhs = ComponentModel(header: Item(title: "foo"), footer: Item(title: "foo"))

    XCTAssertTrue(lhs == rhs)
    XCTAssertTrue(lhs === rhs)
    XCTAssertFalse(lhs != rhs)
    XCTAssertFalse(lhs !== rhs)
    XCTAssertEqual(lhs.diff(model: rhs), ComponentModelDiff.none)

    rhs.header = nil
    XCTAssertFalse(lhs == rhs)
    XCTAssertFalse(lhs === rhs)
    XCTAssertTrue(lhs != rhs)
    XCTAssertTrue(lhs !== rhs)
    XCTAssertEqual(lhs.diff(model: rhs), ComponentModelDiff.header)

    lhs.header = nil
    XCTAssertTrue(lhs == rhs)
    XCTAssertTrue(lhs === rhs)
    XCTAssertFalse(lhs != rhs)
    XCTAssertFalse(lhs !== rhs)
    XCTAssertEqual(lhs.diff(model: rhs), ComponentModelDiff.none)

    lhs = ComponentModel(header: Item(title: "bar"), footer: Item(title: "bar"))
    XCTAssertFalse(lhs == rhs)
    XCTAssertFalse(lhs === rhs)
    XCTAssertTrue(lhs != rhs)
    XCTAssertTrue(lhs !== rhs)
    XCTAssertEqual(lhs.diff(model: rhs), ComponentModelDiff.header)

    rhs = ComponentModel(header: Item(title: "foo"), footer: Item(title: "foo"))
    XCTAssertFalse(lhs == rhs)
    XCTAssertFalse(lhs === rhs)
    XCTAssertTrue(lhs != rhs)
    XCTAssertTrue(lhs !== rhs)
    XCTAssertEqual(lhs.diff(model: rhs), ComponentModelDiff.header)

    rhs = ComponentModel(header: Item(title: "bar"), footer: Item(title: "foo"))
    XCTAssertFalse(lhs == rhs)
    XCTAssertFalse(lhs === rhs)
    XCTAssertTrue(lhs != rhs)
    XCTAssertTrue(lhs !== rhs)
    XCTAssertEqual(lhs.diff(model: rhs), ComponentModelDiff.footer)
  }

  func testComponentModelCompareWithIdentifier() {
    let lhs = ComponentModel(identifier: "foo")
    var rhs = ComponentModel(identifier: "foo")

    XCTAssertEqual(lhs, rhs)
    XCTAssertEqual(lhs.diff(model: rhs), ComponentModelDiff.none)

    rhs.identifier = "bar"

    XCTAssertNotEqual(lhs, rhs)
    XCTAssertEqual(lhs.diff(model: rhs), ComponentModelDiff.identifier)
  }

  func testComponentModelsCompareOperators() {
    let lhs = [ComponentModel(identifier: "foo")]
    var rhs = [ComponentModel(identifier: "foo")]

    // Expect the collections to be equal.
    XCTAssertTrue(lhs === rhs)
    XCTAssertTrue(lhs == rhs)
    XCTAssertFalse(lhs != rhs)

    // Expect the collections to not be equal because the identifiers differ.
    rhs = [ComponentModel(identifier: "bar")]
    XCTAssertFalse(lhs === rhs)
    XCTAssertFalse(lhs == rhs)
    XCTAssertTrue(lhs != rhs)

    // Expect the collections to not be equal as the object count differs.
    rhs = [ComponentModel(identifier: "foo"), ComponentModel(identifier: "foo")]
    XCTAssertFalse(lhs === rhs)
    XCTAssertFalse(lhs == rhs)
    XCTAssertTrue(lhs != rhs)
  }

  func testComponentModelCompareWithMeta() {
    let meta = ["foo" : "bar"]
    let lhs = ComponentModel(meta: meta)
    var rhs = ComponentModel(meta: meta)

    XCTAssertEqual(lhs, rhs)
    XCTAssertEqual(lhs.diff(model: rhs), ComponentModelDiff.none)

    rhs.meta = ["bar" : "baz"]

    XCTAssertNotEqual(lhs, rhs)
    XCTAssertEqual(lhs.diff(model: rhs), ComponentModelDiff.meta)
  }

  private func makeModel<T: Codable>(from json: [String: Any]) throws -> T {
    let data = try jsonEncoder.encode(json: json)
    return try jsonDecoder.decode(T.self, from: data)
  }
}
