@testable import Spots
import Foundation
import XCTest

class ComponentSharedTests: XCTestCase {
  class MockView: View {
    var firstName = ""
    var lastName = ""
  }
  struct MockModel: ItemModel {
    var firstName: String
    var lastName: String
    var height: CGFloat

    static func ==(lhs: MockModel, rhs: MockModel) -> Bool {
      return lhs.firstName == rhs.firstName
        && lhs.lastName == rhs.lastName
        && lhs.height == rhs.height
    }
  }

  override func setUp() {
    Configuration.shared.defaultViewSize = .init(width: 0, height: PlatformDefaults.defaultHeight)
    Configuration.shared.registerDefault(view: DefaultItemView.self)
    Configuration.shared.views.purge()
  }

  func testAppendingMultipleItemsToComponent() {
    let listComponent = Component(model: ComponentModel(kind: .list, layout: Layout(span: 1)))
    listComponent.setup(with: CGSize(width: 100, height: 100))
    var items: [Item] = []

    for i in 0..<10 {
      items.append(Item(title: "Item: \(i)"))
    }

    measure {
      for _ in 0..<5 {
        listComponent.append(items)
        listComponent.view.layoutSubviews()
      }
    }

    let expectation = self.expectation(description: "Wait until done")
    Dispatch.after(seconds: 1.0) {
      XCTAssertEqual(listComponent.model.items.count, 500)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testAppendingMultipleItemsToSpotInController() {
    let controller = SpotsController(components: [Component(model: ComponentModel(kind: .list, layout: Layout(span: 1.0)))])
    controller.prepareController()
    var items: [Item] = []

    for i in 0..<10 {
      items.append(Item(title: "Item: \(i)"))
    }

    measure {
      for _ in 0..<5 {
        controller.append(items, componentIndex: 0, withAnimation: .automatic, completion: nil)
        controller.components.forEach { $0.view.layoutSubviews() }
      }
    }

    let expectation = self.expectation(description: "Wait until done")
    Dispatch.after(seconds: 1.0) {
      XCTAssertEqual(controller.components[0].model.items.count, 500)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testResolvingUIFromGridableComponent() {
    let kind = "test-view"

    Configuration.shared.register(view: TestView.self, identifier: kind)

    let parentSize = CGSize(width: 100, height: 100)
    let model = ComponentModel(items: [Item(title: "foo", kind: kind)])
    let component = Component(model: model)
    component.view.frame.size = parentSize
    component.setup(with: parentSize)
    component.layout(with: parentSize)
    component.view.layoutIfNeeded()

    guard let genericView: View = component.ui(at: 0) else {
      XCTFail()
      return
    }

    XCTAssertFalse(type(of: genericView) === GridWrapper.self)
    XCTAssertTrue(type(of: genericView) === TestView.self)
  }

  func testResolvingUIFromListableComponent() {
    let kind = "test-view"

    Configuration.shared.register(view: TestView.self, identifier: kind)

    let parentSize = CGSize(width: 100, height: 100)
    let model = ComponentModel(items: [Item(title: "foo", kind: kind)])
    let component = Component(model: model)

    component.setup(with: parentSize)
    component.layout(with: parentSize)
    component.view.layoutSubviews()

    guard let genericView: View = component.ui(at: 0) else {
      XCTFail()
      return
    }

    XCTAssertFalse(type(of: genericView) === ListWrapper.self)
    XCTAssertTrue(type(of: genericView) === TestView.self)
  }

  func testCarouselComponentConfigurationClosure() {
    Configuration.shared.register(view: TestView.self, identifier: "test-view")

    let items = [Item(title: "Item A", kind: "test-view"), Item(title: "Item B")]
    let component = Component(model: ComponentModel(kind: .carousel, layout: Layout(span: 0.0), items: items))
    component.setup(with: CGSize(width: 100, height: 100))

    var invokeCount = 0
    component.configure = { _ in
      invokeCount += 1
    }

    // This should be invoked twice, once for each view.
    XCTAssertEqual(invokeCount, 2)
  }

  func testListComponentConfigurationClosure() {
    Configuration.shared.register(view: TestView.self, identifier: "test-view")

    let items = [Item(title: "Item A", kind: "test-view"), Item(title: "Item B")]
    let component = Component(model: ComponentModel(kind: .list, items: items))
    component.setup(with: CGSize(width: 100, height: 100))

    var invokeCount = 0
    component.configure = { _ in
      invokeCount += 1
    }

    // This should be invoked twice, once for each view.
    XCTAssertEqual(invokeCount, 2)
  }

  func testListItemOffset() {
    let items = [
      Item(title: "foo"),
      Item(title: "bar"),
      Item(title: "baz")
    ]
    let model = ComponentModel(kind: .list,items: items)
    let component = Component(model: model)
    component.setup(with: CGSize(width: 100, height: 100))

    XCTAssertEqual(component.itemOffset({ $0.title == "bar" }), PlatformDefaults.defaultHeight)
    XCTAssertEqual(component.itemOffset({ $0.title == "bal" }), 0)
  }

  func testGridItemOffset() {
    let items = [
      Item(title: "foo"),
      Item(title: "bar"),
      Item(title: "baz")
    ]
    let model = ComponentModel(kind: .grid, items: items)
    let component = Component(model: model)
    component.setup(with: CGSize(width: 100, height: 100))

    XCTAssertEqual(component.itemOffset({ $0.title == "bar" }), PlatformDefaults.defaultHeight)
    XCTAssertEqual(component.itemOffset({ $0.title == "bal" }), 0)
  }

  func testCarouselItemOffset() {
    let items = [
      Item(title: "foo"),
      Item(title: "bar"),
      Item(title: "baz")
    ]
    let model = ComponentModel(kind: .carousel, items: items)
    let component = Component(model: model)
    component.setup(with: CGSize(width: 100, height: 100))

    XCTAssertEqual(component.itemOffset({ $0.title == "bar" }), 100)
    XCTAssertEqual(component.itemOffset({ $0.title == "bal" }), 0)
  }

  func testResolvingItemModel() {
    Configuration.shared.register(
      presenter: Presenter<MockView, MockModel>(identifier: "Mock") { (view, model, _) -> CGSize in
        view.firstName = model.firstName
        view.lastName = model.lastName
        view.frame.size.height = model.height
        return .init(width: 200, height: model.height)
      }
    )

    let mockModel = MockModel(firstName: "Foo", lastName: "Bar", height: 200)
    let items = [Item(model: mockModel, kind: "Mock")]
    let model = ComponentModel(items: items)
    let component = Component(model: model)
    component.setup(with: CGSize(width: 200, height: 200))

    guard let resolvedModel: MockModel = component.itemModel(at: 0) else {
      XCTFail("Unable to resolve the model")
      return
    }

    XCTAssertEqual(mockModel, resolvedModel)
  }
}
