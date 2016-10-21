@testable import Spots
import Brick
import Foundation
import XCTest

extension Controller {

  func preloadView() {
    let _ = view
  }

  func viewDidAppear() {
    viewWillAppear(true)
    viewDidAppear(true)
  }

  func scrollTo(_ point: CGPoint) {
    scrollView.setContentOffset(point, animated: false)
    scrollView.layoutSubviews()
  }
}

class SpotsScrollViewTests: XCTestCase {

  var bounds: CGRect!
  var controller: Controller!

  var initialJSON: [String : Any] {
    let listItems: [[String : Any]] = [
      [
        "title" : "Item",
        "size" : ["height" : 80.0]
      ],
      [
        "title" : "Item",
        "size" : ["height" : 80.0]
      ],
      [
        "title" : "Item",
        "size" : ["height" : 80.0]
      ],
      [
        "title" : "Item",
        "size" : ["height" : 80.0]
      ]
    ]

    return [
      "components" : [
        [
          "kind" : "list",
          "items" : listItems
        ],
        [
          "kind" : "list",
          "items" : listItems
        ],
        [
          "kind" : "list",
          "items" : listItems
        ],
        [
          "kind" : "list",
          "items" : listItems
        ],
      ]
    ]
  }

  override func setUp() {
    super.setUp()

    bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: 375, height: 667))
    controller = Controller(initialJSON)
    controller.view.autoresizingMask = []
    controller.view.frame.size = CGSize(width: 375, height: 667)
    controller.preloadView()
    controller.viewWillAppear(true)
  }

  override func tearDown() {
    super.tearDown()

    controller = nil
  }

  func testSpotsScrollView() {
    XCTAssertEqual(controller.scrollView.contentView.subviews.count, 4)
    XCTAssertTrue(controller.scrollView.contentView.subviews[0] is UITableView)
    XCTAssertEqual((controller.scrollView.contentView.subviews[0] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.contentView.subviews[0].frame.height, 320)
    XCTAssertTrue(controller.scrollView.contentView.subviews[1] is UITableView)
    XCTAssertEqual((controller.scrollView.contentView.subviews[1] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.contentView.subviews[1].frame.height, 320)
    XCTAssertTrue(controller.scrollView.contentView.subviews[2] is UITableView)
    XCTAssertEqual((controller.scrollView.contentView.subviews[2] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.contentView.subviews[2].frame.height, 27)
    XCTAssertTrue(controller.scrollView.contentView.subviews[3] is UITableView)
    XCTAssertEqual((controller.scrollView.contentView.subviews[3] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.contentView.subviews[3].frame.height, 0)

    controller.scrollTo(CGPoint(x: 0, y: 160))

    XCTAssertTrue(controller.scrollView.contentView.subviews[0] is UITableView)
    XCTAssertEqual((controller.scrollView.contentView.subviews[0] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.contentView.subviews[0].frame.height, 160)
    XCTAssertTrue(controller.scrollView.contentView.subviews[1] is UITableView)
    XCTAssertEqual((controller.scrollView.contentView.subviews[1] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.contentView.subviews[1].frame.height, 320)
    XCTAssertTrue(controller.scrollView.contentView.subviews[2] is UITableView)
    XCTAssertEqual((controller.scrollView.contentView.subviews[2] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.contentView.subviews[2].frame.height, 187)
    XCTAssertTrue(controller.scrollView.contentView.subviews[3] is UITableView)
    XCTAssertEqual((controller.scrollView.contentView.subviews[3] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.contentView.subviews[3].frame.height, 0)

    controller.scrollTo(CGPoint(x: 0, y: 320))

    XCTAssertTrue(controller.scrollView.contentView.subviews[0] is UITableView)
    XCTAssertEqual((controller.scrollView.contentView.subviews[0] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.contentView.subviews[0].frame.height, 0)
    XCTAssertTrue(controller.scrollView.contentView.subviews[1] is UITableView)
    XCTAssertEqual((controller.scrollView.contentView.subviews[1] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.contentView.subviews[1].frame.height, 320)
    XCTAssertTrue(controller.scrollView.contentView.subviews[2] is UITableView)
    XCTAssertEqual((controller.scrollView.contentView.subviews[2] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.contentView.subviews[2].frame.height, 320)
    XCTAssertTrue(controller.scrollView.contentView.subviews[3] is UITableView)
    XCTAssertEqual((controller.scrollView.contentView.subviews[3] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.contentView.subviews[3].frame.height, 27)

    controller.scrollTo(CGPoint(x: 0, y: 480))

    XCTAssertTrue(controller.scrollView.contentView.subviews[0] is UITableView)
    XCTAssertEqual((controller.scrollView.contentView.subviews[0] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.contentView.subviews[0].frame.height, 0)
    XCTAssertTrue(controller.scrollView.contentView.subviews[1] is UITableView)
    XCTAssertEqual((controller.scrollView.contentView.subviews[1] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.contentView.subviews[1].frame.height, 160)
    XCTAssertTrue(controller.scrollView.contentView.subviews[2] is UITableView)
    XCTAssertEqual((controller.scrollView.contentView.subviews[2] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.contentView.subviews[2].frame.height, 320)
    XCTAssertTrue(controller.scrollView.contentView.subviews[3] is UITableView)
    XCTAssertEqual((controller.scrollView.contentView.subviews[3] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.contentView.subviews[3].frame.height, 187)

    controller.scrollTo(CGPoint(x: 0, y: 544))

    XCTAssertTrue(controller.scrollView.contentView.subviews[0] is UITableView)
    XCTAssertEqual((controller.scrollView.contentView.subviews[0] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.contentView.subviews[0].frame.height, 0)
    XCTAssertTrue(controller.scrollView.contentView.subviews[1] is UITableView)
    XCTAssertEqual((controller.scrollView.contentView.subviews[1] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.contentView.subviews[1].frame.height, 96)
    XCTAssertTrue(controller.scrollView.contentView.subviews[2] is UITableView)
    XCTAssertEqual((controller.scrollView.contentView.subviews[2] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.contentView.subviews[2].frame.height, 320)
    XCTAssertTrue(controller.scrollView.contentView.subviews[3] is UITableView)
    XCTAssertEqual((controller.scrollView.contentView.subviews[3] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.contentView.subviews[3].frame.height, 251)

    controller.scrollTo(CGPoint(x: 0, y: bounds.height))

    XCTAssertTrue(controller.scrollView.contentView.subviews[0] is UITableView)
    XCTAssertEqual((controller.scrollView.contentView.subviews[0] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.contentView.subviews[0].frame.height, 0)
    XCTAssertTrue(controller.scrollView.contentView.subviews[1] is UITableView)
    XCTAssertEqual((controller.scrollView.contentView.subviews[1] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.contentView.subviews[1].frame.height, 0)
    XCTAssertTrue(controller.scrollView.contentView.subviews[2] is UITableView)
    XCTAssertEqual((controller.scrollView.contentView.subviews[2] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.contentView.subviews[2].frame.height, abs(bounds.height - 320 * 3))
    XCTAssertTrue(controller.scrollView.contentView.subviews[3] is UITableView)
    XCTAssertEqual((controller.scrollView.contentView.subviews[3] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.contentView.subviews[3].frame.height, 320)

    controller.scrollTo(CGPoint(x: 0, y: controller.scrollView.contentSize.height))

    XCTAssertTrue(controller.scrollView.contentView.subviews[0] is UITableView)
    XCTAssertEqual((controller.scrollView.contentView.subviews[0] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.contentView.subviews[0].frame.height, 0)
    XCTAssertTrue(controller.scrollView.contentView.subviews[1] is UITableView)
    XCTAssertEqual((controller.scrollView.contentView.subviews[1] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.contentView.subviews[1].frame.height, 0)
    XCTAssertTrue(controller.scrollView.contentView.subviews[2] is UITableView)
    XCTAssertEqual((controller.scrollView.contentView.subviews[2] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.contentView.subviews[2].frame.height, 0)
    XCTAssertTrue(controller.scrollView.contentView.subviews[3] is UITableView)
    XCTAssertEqual((controller.scrollView.contentView.subviews[3] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.scrollView.contentView.subviews[3].frame.height, 0)
  }
}
