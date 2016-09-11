@testable import Spots
import Brick
import Foundation
import XCTest

extension SpotsController {

  func preloadView() {
    let _ = view
  }

  func scrollTo(point: CGPoint) {
    spotsScrollView.setContentOffset(point, animated: false)
    spotsScrollView.layoutSubviews()
  }
}

class SpotsScrollViewTests: XCTestCase {

  func testSpotsScrollView() {
    let listItems: [[String : AnyObject]] = [
      [
        "title" : "Item",
        "size" : ["height" : 80]
      ],
      [
        "title" : "Item",
        "size" : ["height" : 80]
      ],
      [
        "title" : "Item",
        "size" : ["height" : 80]
      ],
      [
        "title" : "Item",
        "size" : ["height" : 80]
      ]
    ]

    let initialJSON: [String : AnyObject] = [
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

    let bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: 375, height: 667))
    let controller = SpotsController(initialJSON)
    controller.view.autoresizingMask = .None
    controller.view.frame.size = CGSize(width: 375, height: 667)
    controller.preloadView()
    controller.viewWillAppear(true)

    XCTAssertEqual(controller.spotsScrollView.contentView.subviews.count, 4)
    XCTAssertTrue(controller.spotsScrollView.contentView.subviews[0] is UITableView)
    XCTAssertEqual((controller.spotsScrollView.contentView.subviews[0] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.spotsScrollView.contentView.subviews[0].frame.height, 320)
    XCTAssertTrue(controller.spotsScrollView.contentView.subviews[1] is UITableView)
    XCTAssertEqual((controller.spotsScrollView.contentView.subviews[1] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.spotsScrollView.contentView.subviews[1].frame.height, 320)
    XCTAssertTrue(controller.spotsScrollView.contentView.subviews[2] is UITableView)
    XCTAssertEqual((controller.spotsScrollView.contentView.subviews[2] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.spotsScrollView.contentView.subviews[2].frame.height, 27)
    XCTAssertTrue(controller.spotsScrollView.contentView.subviews[3] is UITableView)
    XCTAssertEqual((controller.spotsScrollView.contentView.subviews[3] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.spotsScrollView.contentView.subviews[3].frame.height, 0)

    controller.scrollTo(CGPoint(x: 0, y: 160))

    XCTAssertTrue(controller.spotsScrollView.contentView.subviews[0] is UITableView)
    XCTAssertEqual((controller.spotsScrollView.contentView.subviews[0] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.spotsScrollView.contentView.subviews[0].frame.height, 160)
    XCTAssertTrue(controller.spotsScrollView.contentView.subviews[1] is UITableView)
    XCTAssertEqual((controller.spotsScrollView.contentView.subviews[1] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.spotsScrollView.contentView.subviews[1].frame.height, 320)
    XCTAssertTrue(controller.spotsScrollView.contentView.subviews[2] is UITableView)
    XCTAssertEqual((controller.spotsScrollView.contentView.subviews[2] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.spotsScrollView.contentView.subviews[2].frame.height, 187)
    XCTAssertTrue(controller.spotsScrollView.contentView.subviews[3] is UITableView)
    XCTAssertEqual((controller.spotsScrollView.contentView.subviews[3] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.spotsScrollView.contentView.subviews[3].frame.height, 0)

    controller.scrollTo(CGPoint(x: 0, y: 320))

    XCTAssertTrue(controller.spotsScrollView.contentView.subviews[0] is UITableView)
    XCTAssertEqual((controller.spotsScrollView.contentView.subviews[0] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.spotsScrollView.contentView.subviews[0].frame.height, 0)
    XCTAssertTrue(controller.spotsScrollView.contentView.subviews[1] is UITableView)
    XCTAssertEqual((controller.spotsScrollView.contentView.subviews[1] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.spotsScrollView.contentView.subviews[1].frame.height, 320)
    XCTAssertTrue(controller.spotsScrollView.contentView.subviews[2] is UITableView)
    XCTAssertEqual((controller.spotsScrollView.contentView.subviews[2] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.spotsScrollView.contentView.subviews[2].frame.height, 320)
    XCTAssertTrue(controller.spotsScrollView.contentView.subviews[3] is UITableView)
    XCTAssertEqual((controller.spotsScrollView.contentView.subviews[3] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.spotsScrollView.contentView.subviews[3].frame.height, 27)

    controller.scrollTo(CGPoint(x: 0, y: 480))

    XCTAssertTrue(controller.spotsScrollView.contentView.subviews[0] is UITableView)
    XCTAssertEqual((controller.spotsScrollView.contentView.subviews[0] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.spotsScrollView.contentView.subviews[0].frame.height, 0)
    XCTAssertTrue(controller.spotsScrollView.contentView.subviews[1] is UITableView)
    XCTAssertEqual((controller.spotsScrollView.contentView.subviews[1] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.spotsScrollView.contentView.subviews[1].frame.height, 160)
    XCTAssertTrue(controller.spotsScrollView.contentView.subviews[2] is UITableView)
    XCTAssertEqual((controller.spotsScrollView.contentView.subviews[2] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.spotsScrollView.contentView.subviews[2].frame.height, 320)
    XCTAssertTrue(controller.spotsScrollView.contentView.subviews[3] is UITableView)
    XCTAssertEqual((controller.spotsScrollView.contentView.subviews[3] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.spotsScrollView.contentView.subviews[3].frame.height, 187)

    controller.scrollTo(CGPoint(x: 0, y: 544))

    XCTAssertTrue(controller.spotsScrollView.contentView.subviews[0] is UITableView)
    XCTAssertEqual((controller.spotsScrollView.contentView.subviews[0] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.spotsScrollView.contentView.subviews[0].frame.height, 0)
    XCTAssertTrue(controller.spotsScrollView.contentView.subviews[1] is UITableView)
    XCTAssertEqual((controller.spotsScrollView.contentView.subviews[1] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.spotsScrollView.contentView.subviews[1].frame.height, 96)
    XCTAssertTrue(controller.spotsScrollView.contentView.subviews[2] is UITableView)
    XCTAssertEqual((controller.spotsScrollView.contentView.subviews[2] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.spotsScrollView.contentView.subviews[2].frame.height, 320)
    XCTAssertTrue(controller.spotsScrollView.contentView.subviews[3] is UITableView)
    XCTAssertEqual((controller.spotsScrollView.contentView.subviews[3] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.spotsScrollView.contentView.subviews[3].frame.height, 251)

    controller.scrollTo(CGPoint(x: 0, y: bounds.height))

    XCTAssertTrue(controller.spotsScrollView.contentView.subviews[0] is UITableView)
    XCTAssertEqual((controller.spotsScrollView.contentView.subviews[0] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.spotsScrollView.contentView.subviews[0].frame.height, 0)
    XCTAssertTrue(controller.spotsScrollView.contentView.subviews[1] is UITableView)
    XCTAssertEqual((controller.spotsScrollView.contentView.subviews[1] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.spotsScrollView.contentView.subviews[1].frame.height, 0)
    XCTAssertTrue(controller.spotsScrollView.contentView.subviews[2] is UITableView)
    XCTAssertEqual((controller.spotsScrollView.contentView.subviews[2] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.spotsScrollView.contentView.subviews[2].frame.height, abs(bounds.height - 320 * 3))
    XCTAssertTrue(controller.spotsScrollView.contentView.subviews[3] is UITableView)
    XCTAssertEqual((controller.spotsScrollView.contentView.subviews[3] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.spotsScrollView.contentView.subviews[3].frame.height, 320)

    controller.scrollTo(CGPoint(x: 0, y: controller.spotsScrollView.contentSize.height))

    XCTAssertTrue(controller.spotsScrollView.contentView.subviews[0] is UITableView)
    XCTAssertEqual((controller.spotsScrollView.contentView.subviews[0] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.spotsScrollView.contentView.subviews[0].frame.height, 0)
    XCTAssertTrue(controller.spotsScrollView.contentView.subviews[1] is UITableView)
    XCTAssertEqual((controller.spotsScrollView.contentView.subviews[1] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.spotsScrollView.contentView.subviews[1].frame.height, 0)
    XCTAssertTrue(controller.spotsScrollView.contentView.subviews[2] is UITableView)
    XCTAssertEqual((controller.spotsScrollView.contentView.subviews[2] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.spotsScrollView.contentView.subviews[2].frame.height, 0)
    XCTAssertTrue(controller.spotsScrollView.contentView.subviews[3] is UITableView)
    XCTAssertEqual((controller.spotsScrollView.contentView.subviews[3] as? UIScrollView)!.contentSize.height, 320)
    XCTAssertEqual(controller.spotsScrollView.contentView.subviews[3].frame.height, 0)
  }
}
