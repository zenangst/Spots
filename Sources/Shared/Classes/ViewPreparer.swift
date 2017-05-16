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
      prepareItemConfigurableView(view, atIndex: index, in: component, configureView: true)
    default:
      assertionFailure("Unable to prepare view.")
    }
  }

  func prepareWrappableView(_ view: Wrappable, atIndex index: Int, in component: Component, parentFrame: CGRect = CGRect.zero) {
    let identifier = component.identifier(at: index)

    if identifier.contains(CompositeComponent.identifier),
      let composite = component.compositeComponents.filter({ $0.itemIndex == index }).first {
      view.configure(with: composite.component.view)
      component.model.items[index].size.height = composite.component.computedHeight
    } else if let wrappedView = Configuration.views.make(identifier, parentFrame: parentFrame)?.view {
      view.configure(with: wrappedView)
      if let configurableView = wrappedView as? ItemConfigurable {
        prepareItemConfigurableView(configurableView, atIndex: index, in: component, configureView: false)
      } else {
        component.model.items[index].size.height = wrappedView.frame.size.height
      }
    }
  }

  func prepareItemConfigurableView(_ view: ItemConfigurable, atIndex index: Int, in component: Component, configureView: Bool = false) {
    view.configure(with: component.model.items[index])
    if component.model.items[index].size.height == 0.0 {
      component.model.items[index].size = view.computeSize(for: component.model.items[index])
    }

    if configureView {
      component.configure?(view)
    }
  }
}
