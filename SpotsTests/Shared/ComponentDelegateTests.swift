import XCTest
@testable import Spots

class ComponentDelegateTests: XCTest {
    class EmptyComponentDelegate: NSObject, ComponentDelegate {}
    
    func testEmptyComponentDelegate() {
        let delegate = EmptyComponentDelegate()
        let component = Component(model: ComponentModel())
        component.delegate = delegate
        let item = Item()
        let view = View()

        delegate.component(component, itemSelected: item)
        delegate.component(component, willDisplay: view, item: item)
        delegate.component(component, didEndDisplaying: view, item: item)
        delegate.componentsDidChange([])
    }
}
