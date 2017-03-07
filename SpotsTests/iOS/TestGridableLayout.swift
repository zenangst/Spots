@testable import Spots
import Foundation
import XCTest

class TestGridableLayout: XCTestCase {

  let parentSize = CGSize(width: 100, height: 100)

  func testContentSizeForHorizontalLayoutsWithoutInsets() {
    let model = ComponentModel(
      items: [
        Item(title: "foo", size: CGSize(width: 50, height: 50)),
        Item(title: "bar", size: CGSize(width: 50, height: 50))
      ]
    )
    let carouselSpot = CarouselSpot(model: model)
    carouselSpot.setup(parentSize)
    carouselSpot.layout(parentSize)
    carouselSpot.view.layoutSubviews()

    XCTAssertEqual(carouselSpot.layout.contentSize, CGSize(width: 100, height: 50))
    XCTAssertEqual(carouselSpot.view.frame.size, CGSize(width: 100, height: 50))
  }

  func testContentSizeForHorizontalLayoutsWithInsets() {
    let model = ComponentModel(
      layout: Layout(
        inset: Inset(top: 25, left: 25, bottom: 25, right: 25)
      ),
      items: [
        Item(title: "foo", size: CGSize(width: 50, height: 100)),
        Item(title: "bar", size: CGSize(width: 50, height: 100))
      ]
    )
    let carouselSpot = CarouselSpot(model: model)
    carouselSpot.setup(parentSize)
    carouselSpot.layout(parentSize)
    carouselSpot.view.layoutSubviews()

    XCTAssertEqual(carouselSpot.layout.contentSize, CGSize(width: 100, height: 150))
    XCTAssertEqual(carouselSpot.view.frame.size, CGSize(width: 100, height: 150))
  }

  func testLayoutAttributesForElementInHorizontalLayoutWithInsets() {
    let itemSize = CGSize(width: 50, height: 100)
    let model = ComponentModel(
      layout: Layout(
        inset: Inset(top: 25, left: 25, bottom: 25, right: 25)
      ),
      items: [
        Item(title: "foo", size: itemSize),
        Item(title: "bar", size: itemSize)
      ]
    )
    let carouselSpot = CarouselSpot(model: model)
    carouselSpot.setup(parentSize)
    carouselSpot.layout(parentSize)
    carouselSpot.view.layoutSubviews()

    let layoutAttributes = carouselSpot.layout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: parentSize))

    let expectedFrameA = CGRect(
      origin: CGPoint(
        x: model.layout!.inset.left,
        y: model.layout!.inset.top
      ),
      size: itemSize
    )

    let expectedFrameB = CGRect(
      origin: CGPoint(
        x: model.layout!.inset.left + Double(itemSize.width),
        y: model.layout!.inset.top
      ),
      size: itemSize
    )

    XCTAssertEqual(layoutAttributes?.count, 2)
    XCTAssertEqual(layoutAttributes?[0].frame, expectedFrameA)
    XCTAssertEqual(layoutAttributes?[1].frame, expectedFrameB)
  }

  func testLayoutAttributesForElementInHorizontalLayoutWithItemSpacing() {
    let itemSize = CGSize(width: 50, height: 100)
    let model = ComponentModel(
      layout: Layout(
        itemSpacing: 10.0
      ),
      items: [
        Item(title: "foo", size: itemSize),
        Item(title: "bar", size: itemSize)
      ]
    )
    let carouselSpot = CarouselSpot(model: model)
    carouselSpot.setup(parentSize)
    carouselSpot.layout(parentSize)
    carouselSpot.view.layoutSubviews()

    let layoutAttributes = carouselSpot.layout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: parentSize))

    XCTAssertEqual(layoutAttributes?.count, 2)
    XCTAssertEqual(layoutAttributes?[0].frame, CGRect(origin: CGPoint(x: 0.0, y: model.layout!.inset.top), size: itemSize))
    XCTAssertEqual(layoutAttributes?[1].frame, CGRect(origin: CGPoint(x: Double(itemSize.width) + model.layout!.itemSpacing, y: model.layout!.inset.top), size: itemSize))
  }

  func testLayoutAttributesForElementInVerticalLayoutWithInsets() {
    let itemSize = CGSize(width: 25, height: 25)
    let model = ComponentModel(
      layout: Layout(
        itemSpacing: 0,
        inset: Inset(top: 10, left: 30, bottom: 40, right: 20)
      ),
      items: [
        Item(title: "A", size: itemSize),
        Item(title: "B", size: itemSize),
        Item(title: "C", size: itemSize),
        Item(title: "D", size: itemSize)
      ]
    )

    let spot = GridSpot(model: model)
    spot.setup(parentSize)
    spot.layout(parentSize)
    spot.view.layoutSubviews()

    let layoutAttributes = spot.layout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: parentSize))

    let expectedFrameA = CGRect(
      origin: CGPoint(
        x: model.layout!.inset.left,
        y: model.layout!.inset.top
      ),
      size: itemSize
    )

    let expectedFrameB = CGRect(
      origin: CGPoint(
        x: model.layout!.inset.left + Double(itemSize.width),
        y: model.layout!.inset.top
      ),
      size: itemSize
    )

    let expectedFrameC = CGRect(
      origin: CGPoint(
        x: model.layout!.inset.left,
        y: model.layout!.inset.top + Double(itemSize.height)
      ),
      size: itemSize
    )

    let expectedFrameD = CGRect(
      origin: CGPoint(
        x: model.layout!.inset.left + Double(itemSize.width),
        y: model.layout!.inset.top + Double(itemSize.height)
      ),
      size: itemSize
    )

    XCTAssertEqual(layoutAttributes?.count, 4)
    XCTAssertEqual(layoutAttributes?[0].frame, expectedFrameA)
    XCTAssertEqual(layoutAttributes?[1].frame, expectedFrameB)
    XCTAssertEqual(layoutAttributes?[2].frame, expectedFrameC)
    XCTAssertEqual(layoutAttributes?[3].frame, expectedFrameD)

    let expectedContentSize = CGSize(
      width: model.layout!.inset.left + model.layout!.inset.right + Double(itemSize.width) * 2,
      height: model.layout!.inset.top + model.layout!.inset.bottom + Double(itemSize.height) * 2
    )

    XCTAssertEqual(spot.layout.collectionViewContentSize, expectedContentSize)
  }
}
