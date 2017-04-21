#if os(OSX)
  import Foundation
#else
  import UIKit
#endif

class ViewPreparer {

  func prepareView(_ view: View, atIndex index: Int, in component: Component, parentFrame: CGRect = CGRect.zero) {
    switch view {
    case let view as Wrappable:
      prepareWrappableView(view, atIndex: index, in: component, parentFrame: parentFrame)
    case let view as ItemConfigurable:
      prepareItemConfigurableView(view, atIndex: index, in: component)
    default:
      assertionFailure("Unable to prepare view.")
    }
  }

  func prepareWrappableView(_ view: Wrappable, atIndex index: Int, in component: Component, parentFrame: CGRect = CGRect.zero) {
    let identifier = component.identifier(at: index)

    if identifier.contains(CompositeComponent.identifier), index < component.compositeComponents.count {
      let composite = component.compositeComponents[index]
      view.configure(with: composite.component.view)
      component.model.items[index].size.height = composite.component.computedHeight
    } else if let (_, customView) = Configuration.views.make(identifier, parentFrame: parentFrame),
      let wrappedView = customView {
      view.configure(with: wrappedView)

      if let configurableView = customView as? ItemConfigurable {
        configurableView.configure(&component.model.items[index])

        if component.model.items[index].size.height == 0.0 {
          component.model.items[index].size = configurableView.preferredViewSize
        }
      } else {
        component.model.items[index].size.height = wrappedView.frame.size.height
      }
    }
  }

  func prepareItemConfigurableView(_ view: ItemConfigurable, atIndex index: Int, in component: Component) {
    view.configure(&component.model.items[index])

    if component.model.items[index].size.height == 0.0 {
      component.model.items[index].size = view.preferredViewSize
    }
    component.configure?(view)
  }
}
