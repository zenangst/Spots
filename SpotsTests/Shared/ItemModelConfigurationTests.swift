@testable import Spots
import Foundation
import XCTest

class ItemModelConfigurationTests: XCTestCase {
  class MockView: View {
    var firstName = ""
    var lastName = ""
  }
  struct MockModel: ItemModel {
    var itemIdentifier: String
    var firstName: String
    var lastName: String
  }

  func testConfiguringViewWithItemModel() {
    Configuration.register(view: MockView.self,
                           identifier: "Mock",
                           model: MockModel.self,
                           presenter: Presenter(closure: { (view, model, containerSize) -> CGSize in
                            view.firstName = model.firstName
                            view.lastName = model.lastName
                            return .init(width: 200, height: 200)
                           }))

    let mockModel = MockModel(itemIdentifier: "1", firstName: "Foo", lastName: "Bar")
    let items = [
      Item(model: mockModel, kind: "Mock")
    ]
    let model = ComponentModel(kind: .grid, items: items)
    let component = Component(model: model)
    component.setup(with: .init(width: 500, height: 500))

    guard let view: MockView = component.userInterface?.view(at: 0) else {
      XCTFail("Unable to resolve the view")
      return
    }

    XCTAssertEqual(view.firstName, mockModel.firstName)
    XCTAssertEqual(view.lastName, mockModel.lastName)
    XCTAssertEqual(component.item(at: 0)?.size, CGSize(width: 200, height: 200))
  }

}
