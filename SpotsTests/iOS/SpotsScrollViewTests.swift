@testable import Spots
import Foundation
import XCTest

class SpotsScrollViewTests: XCTestCase {

  var bounds: CGRect!
  var controller: SpotsController!

  var initialJSON: [String : Any] {
    let listItems: [[String : Any]] = [
      [
        "title": "Item",
        "size": ["height": 80.0]
      ],
      [
        "title": "Item",
        "size": ["height": 80.0]
      ],
      [
        "title": "Item",
        "size": ["height": 80.0]
      ],
      [
        "title": "Item",
        "size": ["height": 80.0]
      ]
    ]

    return [
      "components": [
        [
          "kind": "list",
          "items": listItems
        ],
        [
          "kind": "list",
          "items": listItems
        ],
        [
          "kind": "list",
          "items": listItems
        ],
        [
          "kind": "list",
          "items": listItems
        ],
      ]
    ]
  }

  override func setUp() {
    super.setUp()
    bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: 375, height: 667))
    controller = SpotsController(initialJSON)
    controller.preloadView()
    controller.view.autoresizingMask = []
    controller.view.frame.size = bounds.size
    controller.configure(withSize: bounds.size)
    controller.viewWillAppear(true)
    controller.scrollView.layoutViews()
  }

  override func tearDown() {
    super.tearDown()

    controller = nil
  }

  func testSpotsScrollView() {
    XCTAssertEqual(controller.scrollView.componentsView.subviews.count, 4)
    XCTAssertTrue(controller.scrollView.componentsView.subviews[0] is UITableView)
    XCTAssertEqual((controller.scrollView.componentsView.subviews[0] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.componentsView.subviews[0].frame.height, 320)
    XCTAssertTrue(controller.scrollView.componentsView.subviews[1] is UITableView)
    XCTAssertEqual((controller.scrollView.componentsView.subviews[1] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.componentsView.subviews[1].frame.height, 320)
    XCTAssertTrue(controller.scrollView.componentsView.subviews[2] is UITableView)
    XCTAssertEqual((controller.scrollView.componentsView.subviews[2] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.componentsView.subviews[2].frame.height, 27)
    XCTAssertTrue(controller.scrollView.componentsView.subviews[3] is UITableView)
    XCTAssertEqual((controller.scrollView.componentsView.subviews[3] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.componentsView.subviews[3].frame.height, 0)

    controller.scrollTo(CGPoint(x: 0, y: 160))

    XCTAssertTrue(controller.scrollView.componentsView.subviews[0] is UITableView)
    XCTAssertEqual((controller.scrollView.componentsView.subviews[0] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.componentsView.subviews[0].frame.height, 160)
    XCTAssertTrue(controller.scrollView.componentsView.subviews[1] is UITableView)
    XCTAssertEqual((controller.scrollView.componentsView.subviews[1] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.componentsView.subviews[1].frame.height, 320)
    XCTAssertTrue(controller.scrollView.componentsView.subviews[2] is UITableView)
    XCTAssertEqual((controller.scrollView.componentsView.subviews[2] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.componentsView.subviews[2].frame.height, 187)
    XCTAssertTrue(controller.scrollView.componentsView.subviews[3] is UITableView)
    XCTAssertEqual((controller.scrollView.componentsView.subviews[3] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.componentsView.subviews[3].frame.height, 0)

    controller.scrollTo(CGPoint(x: 0, y: 320))

    XCTAssertTrue(controller.scrollView.componentsView.subviews[0] is UITableView)
    XCTAssertEqual((controller.scrollView.componentsView.subviews[0] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.componentsView.subviews[0].frame.height, 0)
    XCTAssertTrue(controller.scrollView.componentsView.subviews[1] is UITableView)
    XCTAssertEqual((controller.scrollView.componentsView.subviews[1] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.componentsView.subviews[1].frame.height, 320)
    XCTAssertTrue(controller.scrollView.componentsView.subviews[2] is UITableView)
    XCTAssertEqual((controller.scrollView.componentsView.subviews[2] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.componentsView.subviews[2].frame.height, 320)
    XCTAssertTrue(controller.scrollView.componentsView.subviews[3] is UITableView)
    XCTAssertEqual((controller.scrollView.componentsView.subviews[3] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.componentsView.subviews[3].frame.height, 27)

    controller.scrollTo(CGPoint(x: 0, y: 480))

    XCTAssertTrue(controller.scrollView.componentsView.subviews[0] is UITableView)
    XCTAssertEqual((controller.scrollView.componentsView.subviews[0] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.componentsView.subviews[0].frame.height, 0)
    XCTAssertTrue(controller.scrollView.componentsView.subviews[1] is UITableView)
    XCTAssertEqual((controller.scrollView.componentsView.subviews[1] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.componentsView.subviews[1].frame.height, 160)
    XCTAssertTrue(controller.scrollView.componentsView.subviews[2] is UITableView)
    XCTAssertEqual((controller.scrollView.componentsView.subviews[2] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.componentsView.subviews[2].frame.height, 320)
    XCTAssertTrue(controller.scrollView.componentsView.subviews[3] is UITableView)
    XCTAssertEqual((controller.scrollView.componentsView.subviews[3] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.componentsView.subviews[3].frame.height, 187)

    controller.scrollTo(CGPoint(x: 0, y: 544))

    XCTAssertTrue(controller.scrollView.componentsView.subviews[0] is UITableView)
    XCTAssertEqual((controller.scrollView.componentsView.subviews[0] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.componentsView.subviews[0].frame.height, 0)
    XCTAssertTrue(controller.scrollView.componentsView.subviews[1] is UITableView)
    XCTAssertEqual((controller.scrollView.componentsView.subviews[1] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.componentsView.subviews[1].frame.height, 96)
    XCTAssertTrue(controller.scrollView.componentsView.subviews[2] is UITableView)
    XCTAssertEqual((controller.scrollView.componentsView.subviews[2] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.componentsView.subviews[2].frame.height, 320)
    XCTAssertTrue(controller.scrollView.componentsView.subviews[3] is UITableView)
    XCTAssertEqual((controller.scrollView.componentsView.subviews[3] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.componentsView.subviews[3].frame.height, 251)

    controller.scrollTo(CGPoint(x: 0, y: bounds.height))

    XCTAssertTrue(controller.scrollView.componentsView.subviews[0] is UITableView)
    XCTAssertEqual((controller.scrollView.componentsView.subviews[0] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.componentsView.subviews[0].frame.height, 0)
    XCTAssertTrue(controller.scrollView.componentsView.subviews[1] is UITableView)
    XCTAssertEqual((controller.scrollView.componentsView.subviews[1] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.componentsView.subviews[1].frame.height, 0)
    XCTAssertTrue(controller.scrollView.componentsView.subviews[2] is UITableView)
    XCTAssertEqual((controller.scrollView.componentsView.subviews[2] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.componentsView.subviews[2].frame.height, abs(bounds.height - 320 * 3))
    XCTAssertTrue(controller.scrollView.componentsView.subviews[3] is UITableView)
    XCTAssertEqual((controller.scrollView.componentsView.subviews[3] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.componentsView.subviews[3].frame.height, 320)

    controller.scrollTo(CGPoint(x: 0, y: controller.scrollView.contentSize.height))

    XCTAssertTrue(controller.scrollView.subviewsInLayoutOrder[0] is UITableView)
    XCTAssertEqual((controller.scrollView.subviewsInLayoutOrder[0] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.subviewsInLayoutOrder[0].frame.height, 0)
    XCTAssertTrue(controller.scrollView.subviewsInLayoutOrder[1] is UITableView)
    XCTAssertEqual((controller.scrollView.subviewsInLayoutOrder[1] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.subviewsInLayoutOrder[1].frame.height, 0)
    XCTAssertTrue(controller.scrollView.subviewsInLayoutOrder[2] is UITableView)
    XCTAssertEqual((controller.scrollView.subviewsInLayoutOrder[2] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.subviewsInLayoutOrder[2].frame.height, 0)
    XCTAssertTrue(controller.scrollView.subviewsInLayoutOrder[3] is UITableView)
    XCTAssertEqual((controller.scrollView.subviewsInLayoutOrder[3] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.subviewsInLayoutOrder[3].frame.height, 0)
  }

  func testStetchLastComponent() {
    let items = [Item(), Item()]
    let model = ComponentModel(items: items)
    let controller = SpotsController(components: [Component(model: model), Component(model: model), Component(model: model)])
    controller.prepareController()
    controller.scrollView.layoutSubviews()

    /// The first and the last component should be equal in height
    XCTAssertEqual(controller.components.first?.view.frame.size, controller.components.last?.view.frame.size)

    controller.scrollView.configuration.stretchLastComponent = true
    controller.scrollView.layoutSubviews()

    /// The first and last component should not be equal as the last one should be stretched.
    XCTAssertNotEqual(controller.components.first?.view.frame.size, controller.components.last?.view.frame.size)

    var totalComponentHeight: CGFloat = 0.0
    for component in controller.components {
      totalComponentHeight += component.view.frame.size.height
    }

    XCTAssertEqual(controller.scrollView.frame.size.height, totalComponentHeight)
  }
}
