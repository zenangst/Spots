@testable import Spots
import XCTest

class InsetTests: XCTestCase {
  private let jsonEncoder = JSONEncoder()
  private let jsonDecoder = JSONDecoder()

  let json: [String : Any] = [
    "top": 1.0,
    "left": 2.0,
    "bottom": 3.0,
    "right": 4.0
  ]

  func testDefaultValues() {
    let contentInset = Inset()

    XCTAssertEqual(contentInset.top, 0.0)
    XCTAssertEqual(contentInset.left, 0.0)
    XCTAssertEqual(contentInset.bottom, 0.0)
    XCTAssertEqual(contentInset.right, 0.0)
  }

  func testPaddingInit() {
    let contentInset = Inset(padding: 10)

    XCTAssertEqual(contentInset.top, 10.0)
    XCTAssertEqual(contentInset.left, 10.0)
    XCTAssertEqual(contentInset.bottom, 10.0)
    XCTAssertEqual(contentInset.right, 10.0)
  }

  func testDecoding() throws {
    let data = try jsonEncoder.encode(json: json)
    let contentInset = try jsonDecoder.decode(Inset.self, from: data)

    XCTAssertEqual(contentInset, Inset(top: 1, left: 2, bottom: 3, right: 4))
  }

  func testEncoding() throws {
    let contentInset = Inset {
      $0.top = 1
      $0.left = 2
      $0.bottom = 3
      $0.right = 4
    }

    let data = try jsonEncoder.encode(contentInset)
    let decodedContentInset = try jsonDecoder.decode(Inset.self, from: data)

    XCTAssertTrue(contentInset == decodedContentInset)
  }

  func testBlockConfiguration() {
    let contentInset = Inset {
      $0.top = 1
      $0.left = 2
      $0.bottom = 3
      $0.right = 4
    }

    XCTAssertEqual(contentInset, Inset(top: 1, left: 2, bottom: 3, right: 4))
  }
}
