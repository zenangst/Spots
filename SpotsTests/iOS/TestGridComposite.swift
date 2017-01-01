@testable import Spots
import Brick
import Foundation
import XCTest

class GridCompositeTests: XCTestCase {

  func testGridComposite() {
    let view = GridComposite()
    var item = Item()
    let gridSpot = CompositeSpot(spot: GridSpot(component: Component()), itemIndex: 0)
    view.configure(&item, compositeSpots: [gridSpot])

    XCTAssertTrue(view.contentView.subviews.count == 1)

    let carouselSpot = CompositeSpot(spot: CarouselSpot(component: Component()), itemIndex: 0)
    let listSpot = CompositeSpot(spot: ListSpot(component: Component()), itemIndex: 0)
    view.configure(&item, compositeSpots: [carouselSpot, listSpot])

    XCTAssertTrue(view.contentView.subviews.count == 3)
    XCTAssertTrue(view.contentView.subviews[0] is UICollectionView)
    XCTAssertTrue(view.contentView.subviews[1] is UICollectionView)
    XCTAssertTrue(view.contentView.subviews[2] is UITableView)

    view.prepareForReuse()
    XCTAssertTrue(view.contentView.subviews.count == 0)

    view.configure(&item, compositeSpots: nil)
    XCTAssertTrue(view.contentView.subviews.count == 0)

    view.configure(&item, compositeSpots: [carouselSpot, listSpot])
    XCTAssertTrue(view.contentView.subviews.count == 2)
    XCTAssertTrue(view.contentView.subviews[0] is UICollectionView)
    XCTAssertTrue(view.contentView.subviews[1] is UITableView)

    let customView = UIView()
    view.contentView.addSubview(customView)
    view.prepareForReuse()
    XCTAssertTrue(view.contentView.subviews.count == 1)
  }
}
