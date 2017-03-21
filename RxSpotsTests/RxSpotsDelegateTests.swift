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
    let component = Component(model: ComponentModel(kind: "list"))
    let item = Item(title: "Test")
    var isCalled = false

    delegateProxy.didSelectItem
      .bindNext({ component, item in
        isCalled = (component.tableView != nil) && item.title == "Test"
      }).addDisposableTo(disposeBag)

    delegateProxy.component(component, itemSelected: item)
    XCTAssertTrue(isCalled)
  }
  
  func testDidChange() {
    let listComponent = Component(model: ComponentModel(kind: "list"))
    let gridComponent = Component(model: ComponentModel(kind: "grid"))
    var isCalled = false

    delegateProxy.didChange
      .bindNext({ components in
        isCalled = (components[0].tableView != nil) && (components[1].collectionView != nil)
      })
      .addDisposableTo(disposeBag)

    delegateProxy.componentsDidChange([listComponent, gridComponent])
    XCTAssertTrue(isCalled)
  }

  func testWillDisplayView() {
    let listComponent = Component(model: ComponentModel(kind: "list"))
    let componentView = ComponentView()
    let item = Item(title: "Test")
    var isCalled = false

    delegateProxy.willDisplayView
      .bindNext({ component, view, item in
        isCalled = (component.tableView != nil) && (view == componentView) && item.title == "Test"
      })
      .addDisposableTo(disposeBag)

    delegateProxy.component(listComponent, willDisplay: componentView, item: item)
    XCTAssertTrue(isCalled)
  }

  func testDidEndDisplayingView() {
    let listComponent = Component(model: ComponentModel(kind: "list"))
    let componentView = ComponentView()
    let item = Item(title: "Test")
    var isCalled = false

    delegateProxy.didEndDisplayingView
      .bindNext({ component, view, item in
        isCalled = (component.tableView != nil) && (view == componentView) && item.title == "Test"
      })
      .addDisposableTo(disposeBag)

    delegateProxy.component(listComponent, didEndDisplaying: componentView, item: item)
    XCTAssertTrue(isCalled)
  }
}
