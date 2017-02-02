@testable import Spots
import Brick
import Foundation
import XCTest

class TestGridableLayout: XCTestCase {

  let parentSize = CGSize(width: 100, height: 100)

  func testContentSizeForHorizontalLayoutsWithoutInsets() {
    let component = Component(
      items: [
        Item(title: "foo", size: CGSize(width: 50, height: 50)),
        Item(title: "bar", size: CGSize(width: 50, height: 50))
      ]
    )
    let carouselSpot = CarouselSpot(component: component)
    carouselSpot.setup(parentSize)
    carouselSpot.layout(parentSize)
    carouselSpot.view.layoutSubviews()
    
    XCTAssertEqual(carouselSpot.layout.contentSize, CGSize(width: 100, height: 50))
    XCTAssertEqual(carouselSpot.view.frame.size, CGSize(width: 100, height: 50))
  }

  func testContentSizeForHorizontalLayoutsWithInsets() {
    let component = Component(
      layout: Layout(
        inset: Inset(top: 25, left: 25, bottom: 25, right: 25)
      ),
      items: [
        Item(title: "foo", size: CGSize(width: 50, height: 100)),
        Item(title: "bar", size: CGSize(width: 50, height: 100))
      ]
    )
    let carouselSpot = CarouselSpot(component: component)
    carouselSpot.setup(parentSize)
    carouselSpot.layout(parentSize)
    carouselSpot.view.layoutSubviews()

    XCTAssertEqual(carouselSpot.layout.contentSize, CGSize(width: 100, height: 150))
    XCTAssertEqual(carouselSpot.view.frame.size, CGSize(width: 100, height: 150))
  }

  func testLayoutAttributesForElementInHorizontalLayoutWithInsets() {
    let itemSize = CGSize(width: 50, height: 100)
    let component = Component(
      layout: Layout(
        inset: Inset(top: 25, left: 25, bottom: 25, right: 25)
      ),
      items: [
        Item(title: "foo", size: itemSize),
        Item(title: "bar", size: itemSize)
      ]
    )
    let carouselSpot = CarouselSpot(component: component)
    carouselSpot.setup(parentSize)
    carouselSpot.layout(parentSize)
    carouselSpot.view.layoutSubviews()

    let layoutAttributes = carouselSpot.layout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: parentSize))

    XCTAssertEqual(layoutAttributes?.count, 2)
    XCTAssertEqual(layoutAttributes?[0].frame, CGRect(origin: CGPoint(x: 0.0, y: component.layout!.inset.top), size: itemSize))
    XCTAssertEqual(layoutAttributes?[1].frame, CGRect(origin: CGPoint(x: Double(itemSize.width), y: component.layout!.inset.top), size: itemSize))
  }

  func testLayoutAttributesForElementInHorizontalLayoutWithItemSpacing() {
    let itemSize = CGSize(width: 50, height: 100)
    let component = Component(
      layout: Layout(
        itemSpacing: 10.0
      ),
      items: [
        Item(title: "foo", size: itemSize),
        Item(title: "bar", size: itemSize)
      ]
    )
    let carouselSpot = CarouselSpot(component: component)
    carouselSpot.setup(parentSize)
    carouselSpot.layout(parentSize)
    carouselSpot.view.layoutSubviews()

    let layoutAttributes = carouselSpot.layout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: parentSize))

    XCTAssertEqual(layoutAttributes?.count, 2)
    XCTAssertEqual(layoutAttributes?[0].frame, CGRect(origin: CGPoint(x: 0.0, y: component.layout!.inset.top), size: itemSize))
    XCTAssertEqual(layoutAttributes?[1].frame, CGRect(origin: CGPoint(x: Double(itemSize.width) + component.layout!.itemSpacing, y: component.layout!.inset.top), size: itemSize))
  }
}
