import XCTest
@testable import Spots

class ComponentTableViewTests: XCTestCase {
  class ComponentMock: Component {
    var didLayoutSubviews: Bool = false
    override func layoutSubviews() {
      didLayoutSubviews = true
    }
  }

  func testComponentCollectionView() {
    let component = ComponentMock(model: ComponentModel())
    let tableView = ComponentTableView()
    XCTAssertNil(tableView.component)

    tableView.component = component

    XCTAssertFalse(component.didLayoutSubviews)
    XCTAssertFalse(tableView.canBecomeFocused)

    tableView.setNeedsLayout()
    tableView.layoutIfNeeded()

    XCTAssertTrue(component.didLayoutSubviews)
  }
}

