@testable import Spots
import XCTest

class ComponentFocusDelegateTests: XCTestCase {
  class CollectionViewFocusUpdateContextMock: UICollectionViewFocusUpdateContext {
    override var nextFocusedIndexPath: IndexPath? {
      return IndexPath(item: 0, section: 0)
    }
  }

  class TableViewFocusUpdateContextMock: UITableViewFocusUpdateContext {
    override var nextFocusedIndexPath: IndexPath? {
      return IndexPath(row: 0, section: 0)
    }
  }

  func testFocusedDelegatePropertiesOnCollectionView() {
    let collectionViewContextMock = CollectionViewFocusUpdateContextMock()
    let (component, controller) = createComponentWithController(ofKind: .grid)

    guard let collectionView = component.collectionView else {
      XCTFail("Could not resolve .collectionView")
      return
    }

    // Trigger a focus update using the mocked context.
    let _ = collectionView.delegate?.collectionView!(collectionView,
                                                     shouldUpdateFocusIn: collectionViewContextMock)

    let firstView = component.userInterface?.view(at: 0)
    XCTAssertNotNil(firstView)
    XCTAssertEqual(controller.focusedComponent, component)
    XCTAssertEqual(controller.focusedView, firstView)
    XCTAssertEqual(controller.focusedItemIndex, 0)
  }

  func testFocusedDelegatePropertiesOnTableView() {
    let tableViewContextMock = TableViewFocusUpdateContextMock()
    let (component, controller) = createComponentWithController(ofKind: .list)

    guard let tableView = component.tableView else {
      XCTFail("Could not resolve .tableView")
      return
    }

    // Trigger a focus update using the mocked context.
    let _ = tableView.delegate?.tableView!(tableView, shouldUpdateFocusIn: tableViewContextMock)

    let firstView = component.userInterface?.view(at: 0)
    XCTAssertNotNil(firstView)
    XCTAssertEqual(controller.focusedComponent, component)
    XCTAssertEqual(controller.focusedView, firstView)
    XCTAssertEqual(controller.focusedItemIndex, 0)
  }

  private func createComponentWithController(ofKind kind: ComponentKind) -> (Component, SpotsController) {
    let items = [Item(), Item()]
    let model = ComponentModel(kind: kind, items: items)
    let component = Component(model: model)
    let controller = SpotsController(components: [component])
    controller.prepareController()
    return (component, controller)
  }
}
