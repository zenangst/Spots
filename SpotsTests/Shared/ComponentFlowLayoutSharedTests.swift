@testable import Spots
import Foundation
import XCTest

#if os(macOS)
  import Cocoa
#else
  import UIKit
#endif

class ComponentFlowLayoutSharedTests: XCTestCase {

  override func setUp() {
    Configuration.register(view: TestView.self, identifier: ComponentFlowLayoutSharedTests.identifier)
    Configuration.views.purge()
  }

  static let identifier: String = "MockIdentifier"
  var model = ComponentModel(kind: .carousel,
                             items: (0..<4).flatMap { Item(title: "Test \($0)", kind: identifier) })

  func testRegularCarouselLayout() {
    let layout = Layout()
    let (component, flowLayout) = createComponent(with: layout)
    let layoutAttributes = flowLayout.sharedLayoutAttributesForElements(in: component.view.frame)

    XCTAssertEqual(component.model.items[0].size, CGSize(width: 50, height: 50))
    XCTAssertEqual(component.model.items[1].size, CGSize(width: 50, height: 50))
    XCTAssertEqual(component.model.items[2].size, CGSize(width: 50, height: 50))
    XCTAssertEqual(component.model.items[3].size, CGSize(width: 50, height: 50))

    // Check that the layout attributes correspond to the model sizes
    XCTAssertEqual(component.model.items[0].size, layoutAttributes[0].size)
    XCTAssertEqual(component.model.items[1].size, layoutAttributes[1].size)
    XCTAssertEqual(component.model.items[2].size, layoutAttributes[2].size)
    XCTAssertEqual(component.model.items[3].size, layoutAttributes[3].size)

    // Check that the x coordinate is correct based on padding and item spacing
    XCTAssertEqual(layoutAttributes[0].frame.origin.x, 0)
    XCTAssertEqual(layoutAttributes[1].frame.origin.x, 50)
    XCTAssertEqual(layoutAttributes[2].frame.origin.x, 100)
    XCTAssertEqual(layoutAttributes[3].frame.origin.x, 150)

    XCTAssertEqual(flowLayout.contentSize, CGSize(width: 200, height: 50))
    XCTAssertEqual(flowLayout.contentSize.width, layoutAttributes.last!.frame.maxX)
  }

  func testCarouselLayoutWithSpanOfOne() {
    let layout = Layout(span: 1)
    let (component, flowLayout) = createComponent(with: layout)
    let layoutAttributes = flowLayout.sharedLayoutAttributesForElements(in: component.view.frame)

    XCTAssertEqual(component.model.items[0].size, CGSize(width: 100, height: 50))
    XCTAssertEqual(component.model.items[1].size, CGSize(width: 100, height: 50))
    XCTAssertEqual(component.model.items[2].size, CGSize(width: 100, height: 50))
    XCTAssertEqual(component.model.items[3].size, CGSize(width: 100, height: 50))

    // Check that the layout attributes correspond to the model sizes
    XCTAssertEqual(component.model.items[0].size, layoutAttributes[0].size)
    XCTAssertEqual(component.model.items[1].size, layoutAttributes[1].size)
    XCTAssertEqual(component.model.items[2].size, layoutAttributes[2].size)
    XCTAssertEqual(component.model.items[3].size, layoutAttributes[3].size)

    // Check that the x coordinate is correct based on padding and item spacing
    XCTAssertEqual(layoutAttributes[0].frame.origin.x, 0)
    XCTAssertEqual(layoutAttributes[1].frame.origin.x, 100)
    XCTAssertEqual(layoutAttributes[2].frame.origin.x, 200)
    XCTAssertEqual(layoutAttributes[3].frame.origin.x, 300)

    XCTAssertEqual(flowLayout.contentSize, CGSize(width: 400, height: 50))
    XCTAssertEqual(flowLayout.contentSize.width, layoutAttributes.last!.frame.maxX)
  }

  func testCarouselLayoutWithSpanOfTwo() {
    let layout = Layout(span: 2)
    let (component, flowLayout) = createComponent(with: layout)
    let layoutAttributes = flowLayout.sharedLayoutAttributesForElements(in: component.view.frame)

    XCTAssertEqual(component.model.items[0].size, CGSize(width: 50, height: 50))
    XCTAssertEqual(component.model.items[1].size, CGSize(width: 50, height: 50))
    XCTAssertEqual(component.model.items[2].size, CGSize(width: 50, height: 50))
    XCTAssertEqual(component.model.items[3].size, CGSize(width: 50, height: 50))

    // Check that the layout attributes correspond to the model sizes
    XCTAssertEqual(component.model.items[0].size, layoutAttributes[0].size)
    XCTAssertEqual(component.model.items[1].size, layoutAttributes[1].size)
    XCTAssertEqual(component.model.items[2].size, layoutAttributes[2].size)
    XCTAssertEqual(component.model.items[3].size, layoutAttributes[3].size)

    // Check that the x coordinate is correct based on padding and item spacing
    XCTAssertEqual(layoutAttributes[0].frame.origin.x, 0)
    XCTAssertEqual(layoutAttributes[1].frame.origin.x, 50)
    XCTAssertEqual(layoutAttributes[2].frame.origin.x, 100)
    XCTAssertEqual(layoutAttributes[3].frame.origin.x, 150)

    XCTAssertEqual(flowLayout.contentSize, CGSize(width: 200, height: 50))

    // Check that the content size is equal to the last layout attribute
    XCTAssertEqual(flowLayout.contentSize.width, layoutAttributes.last!.frame.maxX)
  }

  func testCarouselLayoutWithSpanOfOneWithInsetOfTen() {
    let layout = Layout(span: 1, inset: Inset(padding: 10))
    let (component, flowLayout) = createComponent(with: layout)
    let layoutAttributes = flowLayout.sharedLayoutAttributesForElements(in: component.view.frame)

    // The width should be 80 because the component size is 100 and it has 10 in padding on each side.
    XCTAssertEqual(component.model.items[0].size, CGSize(width: 80, height: 50))
    XCTAssertEqual(component.model.items[1].size, CGSize(width: 80, height: 50))
    XCTAssertEqual(component.model.items[2].size, CGSize(width: 80, height: 50))
    XCTAssertEqual(component.model.items[3].size, CGSize(width: 80, height: 50))

    // Check that the layout attributes correspond to the model sizes
    XCTAssertEqual(component.model.items[0].size, layoutAttributes[0].size)
    XCTAssertEqual(component.model.items[1].size, layoutAttributes[1].size)
    XCTAssertEqual(component.model.items[2].size, layoutAttributes[2].size)
    XCTAssertEqual(component.model.items[3].size, layoutAttributes[3].size)

    // Check that the x coordinate is correct based on padding and item spacing
    XCTAssertEqual(layoutAttributes[0].frame.origin.x, 10)
    XCTAssertEqual(layoutAttributes[1].frame.origin.x, 90)
    XCTAssertEqual(layoutAttributes[2].frame.origin.x, 170)
    XCTAssertEqual(layoutAttributes[3].frame.origin.x, 250)

    // The total content size should be the width of the items + padding on each side.
    // In this case that should be the current formula:
    // $totalItemWidth + $leftInset + $rightInset
    //     80 * 4      +     10     +     10
    XCTAssertEqual(flowLayout.contentSize, CGSize(width: 340, height: 70))

    // Check that the content size is equal to the last layout attribute plus right padding
    XCTAssertEqual(flowLayout.contentSize.width, layoutAttributes.last!.frame.maxX + 10)
  }

  func testCarouselLayoutWithSpanOfTwoWithPaddingAndItemSpacing() {
    let layout = Layout(span: 2, itemSpacing: 10, inset: Inset(padding: 10))
    let (component, flowLayout) = createComponent(with: layout)
    let layoutAttributes = flowLayout.sharedLayoutAttributesForElements(in: component.view.frame)

    // The width should be the width of the component (100) divided by 2, then minus the padding which
    // is 10 on each side. We also have an item spacing of 10.
    XCTAssertEqual(component.model.items[0].size, CGSize(width: 30, height: 50))
    XCTAssertEqual(component.model.items[1].size, CGSize(width: 30, height: 50))
    XCTAssertEqual(component.model.items[2].size, CGSize(width: 30, height: 50))
    XCTAssertEqual(component.model.items[3].size, CGSize(width: 30, height: 50))

    // Check that the layout attributes correspond to the model sizes
    XCTAssertEqual(component.model.items[0].size, layoutAttributes[0].size)
    XCTAssertEqual(component.model.items[1].size, layoutAttributes[1].size)
    XCTAssertEqual(component.model.items[2].size, layoutAttributes[2].size)
    XCTAssertEqual(component.model.items[3].size, layoutAttributes[3].size)

    // Check that the x coordinate is correct based on padding and item spacing
    XCTAssertEqual(layoutAttributes[0].frame.origin.x, 10)
    XCTAssertEqual(layoutAttributes[1].frame.origin.x, 50)
    XCTAssertEqual(layoutAttributes[2].frame.origin.x, 90)
    XCTAssertEqual(layoutAttributes[3].frame.origin.x, 130)

    // In this case that should be the current formula:
    // $totalItemWidth + $leftInset + $rightInset + ($itemSpacing * $numberOfItems - $itemSpacing)
    //     30 * 4      +     10     +     10      + (     10      *       4        - 10  )
    XCTAssertEqual(flowLayout.contentSize, CGSize(width: 170, height: 70))
    // Check that the content size is equal to the last layout attribute plus right padding
    XCTAssertEqual(flowLayout.contentSize.width, layoutAttributes.last!.frame.maxX + 10)
  }

  private func createComponent(with layout: Layout) -> (Component, ComponentFlowLayout) {
    var model = self.model
    model.layout = layout
    let component = Component(model: model)
    component.setup(with: CGSize(width: 100, height: 100))

    return (component, component.collectionView?.collectionViewLayout as! ComponentFlowLayout)
  }
}

extension ComponentFlowLayout {

  #if os(macOS)
  fileprivate func sharedLayoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
    return layoutAttributesForElements(in: rect)
  }
  #else
  fileprivate func sharedLayoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes] {
    return layoutAttributesForElements(in: rect)!
  }
  #endif
}
