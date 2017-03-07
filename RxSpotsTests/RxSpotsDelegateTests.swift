import XCTest
import Spots
import RxSpots
import RxSwift

class RxComponentDelegateTests: XCTestCase {

  var delegateProxy: RxComponentDelegate!
  private let disposeBag = DisposeBag()

  override func setUp() {
    super.setUp()
    let controller = Controller()

    delegateProxy = RxComponentDelegate(parentObject: controller)
  }

  func testDidSelectItem() {
    let spot = ListComponent()
    let item = Item(title: "Test")
    var isCalled = false

    delegateProxy.didSelectItem
      .bindNext({ spot, item in
        isCalled = (spot is ListComponent) && item.title == "Test"
      }).addDisposableTo(disposeBag)

    delegateProxy.spotable(spot, itemSelected: item)
    XCTAssertTrue(isCalled)
  }
  
  func testDidChange() {
    let listSpot = ListComponent()
    let gridSpot = GridComponent()
    var isCalled = false

    delegateProxy.didChange
      .bindNext({ spots in
        isCalled = (spots[0] is ListComponent) && (spots[1] is GridComponent)
      })
      .addDisposableTo(disposeBag)

    delegateProxy.spotablesDidChange([listSpot, gridSpot])
    XCTAssertTrue(isCalled)
  }

  func testWillDisplayView() {
    let listSpot = ListComponent()
    let spotView = SpotView()
    let item = Item(title: "Test")
    var isCalled = false

    delegateProxy.willDisplayView
      .bindNext({ spot, view, item in
        isCalled = (spot is ListComponent) && (view == spotView) && item.title == "Test"
      })
      .addDisposableTo(disposeBag)

    delegateProxy.spotable(listSpot, willDisplay: spotView, item: item)
    XCTAssertTrue(isCalled)
  }

  func testDidEndDisplayingView() {
    let listSpot = ListComponent()
    let spotView = SpotView()
    let item = Item(title: "Test")
    var isCalled = false

    delegateProxy.didEndDisplayingView
      .bindNext({ spot, view, item in
        isCalled = (spot is ListComponent) && (view == spotView) && item.title == "Test"
      })
      .addDisposableTo(disposeBag)

    delegateProxy.spotable(listSpot, didEndDisplaying: spotView, item: item)
    XCTAssertTrue(isCalled)
  }
}
