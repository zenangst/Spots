import XCTest
@testable import Spots

class ComponentCollectionViewTests: XCTestCase {
  class ComponentMock: Component {
    var didLayoutSubviews: Bool = false
    override func layoutSubviews() {
      didLayoutSubviews = true
    }
  }

  func testComponentCollectionView() {
    let component = ComponentMock(model: ComponentModel())
    let collectionViewLayout = UICollectionViewLayout()
    let collectionView = ComponentCollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    XCTAssertNil(collectionView.component)

    collectionView.component = component

    XCTAssertFalse(component.didLayoutSubviews)
    XCTAssertFalse(collectionView.canBecomeFocused)

    collectionView.setNeedsLayout()
    collectionView.layoutIfNeeded()

    XCTAssertTrue(component.didLayoutSubviews)
  }
}
