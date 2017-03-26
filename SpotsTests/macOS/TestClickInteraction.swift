@testable import Spots
import XCTest

class MockTableView: NSTableView {

  var rowClicked: Int = -1

  override var clickedRow: Int {

    if rowView(atRow: rowClicked, makeIfNecessary: false) != nil {
      return rowClicked
    } else {
      return -1
    }
  }
}

class MockComponentDelegate: NSObject, ComponentDelegate {

  var invocation: Int = 0

  func component(_ component: Component, itemSelected item: Item) {
    invocation += 1
  }
}

class TestClickInteraction: XCTestCase {

  func testClickInteraction() {
    let mockTableView = MockTableView()
    let mockDelegate = MockComponentDelegate()
    let interaction = Interaction(clickInteraction: .single)
    let model = ComponentModel(kind: .list, interaction: interaction, items: [
      Item(title: "foo")
      ]
    )
    let component = Component(model: model, userInterface: mockTableView)
    component.setup(with: CGSize(width: 100, height: 100))
    
    component.delegate = mockDelegate

    guard let tableView = component.tableView as? MockTableView else {
      XCTFail("Unable to resolve table view.")
      return
    }

    tableView.rowClicked = 0

    /// Expect that the component delegate will be called once.
    component.action(nil)
    XCTAssertEqual(mockDelegate.invocation, 1)

    /// Expect that the invocation count is still one after double clicking.
    component.doubleAction(nil)
    XCTAssertEqual(mockDelegate.invocation, 1)

    /// Expect that the invocation is unchanged when the configuration is set
    /// to only accept double clicks.
    component.model.interaction.clickInteraction = .double
    component.action(nil)
    XCTAssertEqual(mockDelegate.invocation, 1)

    /// Expect that invocation is two because it is inline with the configuration.
    component.doubleAction(nil)
    XCTAssertEqual(mockDelegate.invocation, 2)
  }

}
