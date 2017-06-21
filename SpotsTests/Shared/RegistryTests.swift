@testable import Spots
import XCTest

class RegistryTests: XCTestCase {

  class RegistryViewMock: View, ItemConfigurable {
    var title: String = ""

    func configure(with item: Item) {
      title = item.title
    }

    func computeSize(for item: Item) -> CGSize {
      return .zero
    }
  }

  override func setUp() {
    super.setUp()
    Configuration.register(view: RegistryViewMock.self, identifier: "registry-mock")
  }

  func testCreatingView() {
    let frame = CGRect(origin: .zero, size: .init(width: 50, height: 50))
    let item = Item(title: "foo", kind: "registry-mock")
    let view: RegistryViewMock? = Configuration.views.makeView(from: item, with: frame)

    XCTAssertNotNil(view)
    XCTAssertEqual(view?.frame, frame)
    XCTAssertEqual(view?.title, item.title)
  }

}
