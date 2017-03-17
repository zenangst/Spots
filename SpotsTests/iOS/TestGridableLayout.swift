@testable import Spots
import Foundation
import XCTest

class TestGridableLayout: XCTestCase {

  let parentSize = CGSize(width: 100, height: 100)

  func testContentSizeForHorizontalLayoutsWithoutInsets() {
    let model = ComponentModel(
      kind: "carousel",
      items: [
        Item(title: "foo", size: CGSize(width: 50, height: 50)),
        Item(title: "bar", size: CGSize(width: 50, height: 50))
      ]
    )
    let carouselComponent = CarouselComponent(model: model)
    carouselComponent.setup(parentSize)
    carouselComponent.view.layoutSubviews()

    guard let collectionView = carouselComponent.collectionView else {
      XCTFail("Unable to resolve collection view layout.")
      return
    }

    XCTAssertEqual(collectionView.contentSize, CGSize(width: 100, height: 50))
    XCTAssertEqual(carouselComponent.view.frame.size, CGSize(width: 100, height: 50))
  }

  func testContentSizeForHorizontalLayoutsWithInsets() {
    let model = ComponentModel(
      kind: "carousel",
      layout: Layout(
        inset: Inset(top: 25, left: 25, bottom: 25, right: 25)
      ),
      items: [
        Item(title: "foo", size: CGSize(width: 50, height: 100)),
        Item(title: "bar", size: CGSize(width: 50, height: 100))
      ]
    )
    let carouselComponent = CarouselComponent(model: model)
    carouselComponent.setup(parentSize)
    carouselComponent.layout(parentSize)
    carouselComponent.view.layoutSubviews()

    guard let collectionView = carouselComponent.collectionView else {
      XCTFail("Unable to resolve collection view layout.")
      return
    }

    XCTAssertEqual(collectionView.contentSize, CGSize(width: 100, height: 150))
    XCTAssertEqual(carouselComponent.view.frame.size, CGSize(width: 100, height: 150))
  }

  func testLayoutAttributesForElementInHorizontalLayoutWithInsets() {
    let itemSize = CGSize(width: 50, height: 100)
    let model = ComponentModel(
      kind: "carousel",
      layout: Layout(
        inset: Inset(top: 25, left: 25, bottom: 25, right: 25)
      ),
      items: [
        Item(title: "foo", size: itemSize),
        Item(title: "bar", size: itemSize)
      ]
    )
    let carouselComponent = CarouselComponent(model: model)
    carouselComponent.setup(parentSize)
    carouselComponent.view.layoutSubviews()

    guard let collectionViewLayout = carouselComponent.collectionView?.collectionViewLayout as? FlowLayout else {
      XCTFail("Unable to resolve collection view layout.")
      return
    }

    let layoutAttributes = collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: parentSize))

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
      kind: "carousel",
      layout: Layout(
        itemSpacing: 10.0
      ),
      items: [
        Item(title: "foo", size: itemSize),
        Item(title: "bar", size: itemSize)
      ]
    )
    let carouselComponent = CarouselComponent(model: model)
    carouselComponent.setup(parentSize)
    carouselComponent.view.layoutSubviews()

    guard let collectionViewLayout = carouselComponent.collectionView?.collectionViewLayout as? FlowLayout else {
      XCTFail("Unable to resolve collection view layout.")
      return
    }

    let layoutAttributes = collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: parentSize))

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

    let component = GridComponent(model: model)
    component.setup(parentSize)
    component.layout(parentSize)
    component.view.layoutSubviews()

    guard let collectionViewLayout = component.collectionView?.collectionViewLayout as? FlowLayout else {
      XCTFail("Unable to resolve collection view layout.")
      return
    }

    let layoutAttributes = collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: parentSize))

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

    if let collectionViewLayout = component.collectionView?.collectionViewLayout as? FlowLayout {
      XCTFail("Unable to resolve collection view layout.")
      return
    }

    XCTAssertEqual(collectionViewLayout.collectionViewContentSize, expectedContentSize)
  }
}
