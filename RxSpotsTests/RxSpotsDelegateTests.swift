import XCTest
import Spots
import RxSpots
import RxSwift
import Brick

class RxSpotsDelegateTests: XCTestCase {

  var delegateProxy: RxSpotsDelegate!
  private let disposeBag = DisposeBag()

  override func setUp() {
    super.setUp()
    let controller = Controller()

    delegateProxy = RxSpotsDelegate(parentObject: controller)
  }
  
  func testDidSelectItem() {
    let spot = ListSpot()
    let item = Item(title: "Test")
    var isCalled = false

    delegateProxy.didSelectItem.bindNext { spot, item in
      isCalled = (spot is ListSpot) && item.title == "Test"
    }.addDisposableTo(disposeBag)

    delegateProxy.spotable(spot, itemSelected: item)
    XCTAssertTrue(isCalled)
  }
  
  func testDidChange() {
    let listSpot = ListSpot()
    let gridSpot = GridSpot()
    var isCalled = false

    delegateProxy.didChange
      .bindNext({ spots in
        isCalled = (spots[0] is ListSpot) && (spots[1] is GridSpot)
      })
      .addDisposableTo(disposeBag)

    delegateProxy.spotablesDidChange([listSpot, gridSpot])
    XCTAssertTrue(isCalled)
  }

  func testWillDisplayView() {
    let listSpot = ListSpot()
    let spotView = SpotView()
    let item = Item(title: "Test")
    var isCalled = false

    delegateProxy.willDisplayView
      .bindNext({ spot, view, item in
        isCalled = (spot is ListSpot) && (view == spotView) && item.title == "Test"
      })
      .addDisposableTo(disposeBag)

    delegateProxy.spotable(listSpot, willDisplay: spotView, item: item)
    XCTAssertTrue(isCalled)
  }

  func testDidEndDisplayingView() {
    let listSpot = ListSpot()
    let spotView = SpotView()
    let item = Item(title: "Test")
    var isCalled = false

    delegateProxy.didEndDisplayingView
      .bindNext({ spot, view, item in
        isCalled = (spot is ListSpot) && (view == spotView) && item.title == "Test"
      })
      .addDisposableTo(disposeBag)

    delegateProxy.spotable(listSpot, didEndDisplaying: spotView, item: item)
    XCTAssertTrue(isCalled)
  }
}
