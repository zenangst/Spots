@testable import Spots
import XCTest

class ComponentDelegateTests: XCTestCase {
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
    var numberOfItemsSelected: Int = 0
    var lastChangedIndexes: [Int]?

    func component(_ component: Component, itemSelected item: Item) {
      numberOfItemsSelected += 1
    }

    func component(_ component: Component, didChangeSelection selectedIndexes: [Int]) {
      lastChangedIndexes = selectedIndexes
    }
  }

  func testMouseClick() {
    let mockTableView = MockTableView()
    let mockDelegate = MockComponentDelegate()
    let interaction = Interaction(mouseClick: .single)
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
    component.singleMouseClick(nil)
    XCTAssertEqual(mockDelegate.numberOfItemsSelected, 1)

    /// Expect that the invocation count is still one after double clicking.
    component.doubleMouseClick(nil)
    XCTAssertEqual(mockDelegate.numberOfItemsSelected, 1)

    /// Expect that the invocation is unchanged when the configuration is set
    /// to only accept double clicks.
    component.model.interaction.mouseClick = .double
    component.singleMouseClick(nil)
    XCTAssertEqual(mockDelegate.numberOfItemsSelected, 1)

    /// Expect that invocation is two because it is inline with the configuration.
    component.doubleMouseClick(nil)
    XCTAssertEqual(mockDelegate.numberOfItemsSelected, 2)
  }

  func testSelectionDidChange() {
    let items = [Item(), Item(), Item()]
    let model = ComponentModel(kind: .grid, items: items)
    let component = Component(model: model)
    let delegate = MockComponentDelegate()

    component.setup(with: .init(width: 200, height: 200))
    component.delegate = delegate


    // Check that the delegate gets the last selected indexes, it should return an array with indexes with one entry as
    // we only intend to select the very first item in the component.
    component.componentDelegate?.collectionView(component.collectionView!, didSelectItemsAt: [IndexPath(item: 0, section: 0)])
    XCTAssertEqual(delegate.lastChangedIndexes!, [0])

    // Select the second and third item in the list and verify that the stored property on the mocked delegate ends up with the
    // correct indexes.
    let newSelectedItems: Set<IndexPath> = [IndexPath(item: 1, section: 0), IndexPath(item: 2, section: 0)]
    component.componentDelegate?.collectionView(component.collectionView!, didSelectItemsAt: newSelectedItems)
    XCTAssertEqual(delegate.lastChangedIndexes!, [1,2])
  }
}
