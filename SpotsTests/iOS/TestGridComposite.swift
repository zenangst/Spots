@testable import Spots
import Brick
import Foundation
import XCTest

class GridCompositeTests: XCTestCase {

  func testGridComposite() {
    let view = GridComposite()
    var item = Item()
    let gridSpot = GridSpot(component: Component())
    view.configure(&item, spots: [gridSpot])

    XCTAssertTrue(view.contentView.subviews.count == 1)

    let carouselSpot = CarouselSpot(component: Component())
    let listSpot = ListSpot(component: Component())
    view.configure(&item, spots: [carouselSpot, listSpot])

    XCTAssertTrue(view.contentView.subviews.count == 3)
    XCTAssertTrue(view.contentView.subviews[0] is UICollectionView)
    XCTAssertTrue(view.contentView.subviews[1] is UICollectionView)
    XCTAssertTrue(view.contentView.subviews[2] is UITableView)

    view.prepareForReuse()
    XCTAssertTrue(view.contentView.subviews.count == 0)

    view.configure(&item, spots: nil)
    XCTAssertTrue(view.contentView.subviews.count == 0)

    view.configure(&item, spots: [carouselSpot, listSpot])
    XCTAssertTrue(view.contentView.subviews.count == 2)
    XCTAssertTrue(view.contentView.subviews[0] is UICollectionView)
    XCTAssertTrue(view.contentView.subviews[1] is UITableView)

    let customView = UIView()
    view.contentView.addSubview(customView)
    view.prepareForReuse()
    XCTAssertTrue(view.contentView.subviews.count == 1)
  }
  
}
