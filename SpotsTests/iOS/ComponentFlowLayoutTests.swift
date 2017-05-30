@testable import Spots
import Foundation
import XCTest

class ItemsPerRowViewMock: View, ItemConfigurable {

  func configure(with item: Item) {}

  func computeSize(for item: Item) -> CGSize {
    return CGSize(width: 100, height: 50)
  }
}

class ComponentFlowLayoutTests: XCTestCase {

  let parentSize = CGSize(width: 100, height: 100)

  override func setUp() {
    Configuration.registerDefault(view: DefaultItemView.self)
    Configuration.views.purge()
  }

  func testContentSizeForHorizontalLayoutsWithoutInsets() {
    let model = ComponentModel(
      kind: .carousel,
      items: [
        Item(title: "foo", size: CGSize(width: 50, height: 50)),
        Item(title: "bar", size: CGSize(width: 50, height: 50))
      ]
    )
    let carouselComponent = Component(model: model)
    carouselComponent.setup(with: parentSize)

    guard let collectionView = carouselComponent.collectionView else {
      XCTFail("Unable to resolve collection view layout.")
      return
    }

    XCTAssertEqual(collectionView.contentSize, CGSize(width: 100, height: 50))
    XCTAssertEqual(carouselComponent.view.frame.size, CGSize(width: 100, height: 50))
  }

  func testContentSizeForHorizontalLayoutsWithInsets() {

    let model = ComponentModel(
      kind: .carousel,
      layout: Layout(
        inset: Inset(top: 25, left: 25, bottom: 25, right: 25)
      ),
      items: [
        Item(title: "foo", size: CGSize(width: 50, height: 100)),
        Item(title: "bar", size: CGSize(width: 50, height: 100))
      ]
    )
    let carouselComponent = Component(model: model)
    carouselComponent.setup(with: parentSize)

    guard let collectionView = carouselComponent.collectionView else {
      XCTFail("Unable to resolve collection view layout.")
      return
    }

    XCTAssertEqual(collectionView.contentSize, CGSize(width: 150, height: 150))
    XCTAssertEqual(carouselComponent.view.frame.size, CGSize(width: 100, height: 150))
  }

  func testLayoutAttributesForElementInHorizontalLayoutWithInsets() {
    let itemSize = CGSize(width: 50, height: 100)
    let model = ComponentModel(
      kind: .carousel,
      layout: Layout(
        inset: Inset(top: 25, left: 25, bottom: 25, right: 25)
      ),
      items: [
        Item(title: "foo", size: itemSize),
        Item(title: "bar", size: itemSize)
      ]
    )
    let carouselComponent = Component(model: model)
    carouselComponent.setup(with: parentSize)

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
      kind: .carousel,
      layout: Layout(
        itemSpacing: 10.0
      ),
      items: [
        Item(title: "foo", size: itemSize),
        Item(title: "bar", size: itemSize)
      ]
    )
    let carouselComponent = Component(model: model)
    carouselComponent.setup(with: parentSize)

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
      kind: .grid,
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

    let component = Component(model: model)
    component.setup(with: parentSize)

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

    XCTAssertEqual(collectionViewLayout.collectionViewContentSize, expectedContentSize)
  }

  func testItemsPerRow() {
    var component: Component
    var model: ComponentModel
    let items = [
      Item(title: "Item 1"),
      Item(title: "Item 2"),
      Item(title: "Item 3"),
      Item(title: "Item 4"),
      Item(title: "Item 5"),
      Item(title: "Item 6"),
      Item(title: "Item 7"),
      Item(title: "Item 8"),
      Item(title: "Item 9"),
      Item(title: "Item 10"),
      Item(title: "Item 11"),
      Item(title: "Item 12"),
      Item(title: "Item 13"),
      Item(title: "Item 14"),
      Item(title: "Item 15"),
    ]

    model = ComponentModel(kind: .carousel, layout: Layout(itemsPerRow: 1), items: items)
    component = Component(model: model)
    component.setup(with: CGSize(width: 100, height: 100))
    XCTAssertEqual(component.view.contentSize, CGSize(width: 1500, height: 44))

    model = ComponentModel(kind: .carousel, layout: Layout(itemsPerRow: 2), items: items)
    component = Component(model: model)
    component.setup(with: CGSize(width: 100, height: 100))
    XCTAssertEqual(component.view.contentSize, CGSize(width: 800, height: 88))

    model = ComponentModel(kind: .carousel, layout: Layout(itemsPerRow: 3), items: items)
    component = Component(model: model)
    component.setup(with: CGSize(width: 100, height: 100))
    XCTAssertEqual(component.view.contentSize, CGSize(width: 500, height: 132))
  }
}
