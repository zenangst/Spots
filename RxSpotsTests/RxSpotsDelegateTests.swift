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
    let component = ListComponent()
    let item = Item(title: "Test")
    var isCalled = false

    delegateProxy.didSelectItem
      .bindNext({ component, item in
        isCalled = (component is ListComponent) && item.title == "Test"
      }).addDisposableTo(disposeBag)

    delegateProxy.component(component, itemSelected: item)
    XCTAssertTrue(isCalled)
  }
  
  func testDidChange() {
    let listComponent = ListComponent()
    let gridComponent = GridComponent()
    var isCalled = false

    delegateProxy.didChange
      .bindNext({ components in
        isCalled = (components[0] is ListComponent) && (components[1] is GridComponent)
      })
      .addDisposableTo(disposeBag)

    delegateProxy.componentsDidChange([listComponent, gridComponent])
    XCTAssertTrue(isCalled)
  }

  func testWillDisplayView() {
    let listComponent = ListComponent()
    let componentView = ComponentView()
    let item = Item(title: "Test")
    var isCalled = false

    delegateProxy.willDisplayView
      .bindNext({ component, view, item in
        isCalled = (component is ListComponent) && (view == componentView) && item.title == "Test"
      })
      .addDisposableTo(disposeBag)

    delegateProxy.component(listComponent, willDisplay: componentView, item: item)
    XCTAssertTrue(isCalled)
  }

  func testDidEndDisplayingView() {
    let listComponent = ListComponent()
    let componentView = ComponentView()
    let item = Item(title: "Test")
    var isCalled = false

    delegateProxy.didEndDisplayingView
      .bindNext({ component, view, item in
        isCalled = (component is ListComponent) && (view == componentView) && item.title == "Test"
      })
      .addDisposableTo(disposeBag)

    delegateProxy.component(listComponent, didEndDisplaying: componentView, item: item)
    XCTAssertTrue(isCalled)
  }
}
