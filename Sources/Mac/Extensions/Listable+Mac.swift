import Cocoa
import Brick

extension Listable {

  public var responder: NSResponder {
    return tableView
  }

  public var nextResponder: NSResponder? {
    get {
      return tableView.nextResponder
    }
    set {
      tableView.nextResponder = newValue
    }
  }

  public func prepare() {
    var cached: View?
    for (index, item) in component.items.enumerate() {
      prepareItem(item, index: index, cached: &cached)
    }
    cached = nil
  }

  public func prepareItem(item: ViewModel, index: Int, inout cached: View?) {
    cachedViewFor(item, cache: &cached)

    component.items[index].index = index

    guard let view = cached as? SpotConfigurable else { return }

    view.configure(&component.items[index])

    if component.items[index].size.height == 0.0 {
      component.items[index].size.height = view.size.height
    }

    if component.items[index].size.width == 0.0 {
      component.items[index].size.width = view.size.width
    }
  }

  func cachedViewFor(item: ViewModel, inout cache: View?) {
    let reuseIdentifer = item.kind.isPresent ? item.kind : component.kind
    let componentClass = self.dynamicType.views.storage[reuseIdentifer] ?? self.dynamicType.defaultView

    if cache?.isKindOfClass(componentClass) == false { cache = nil }
    if cache == nil { cache = componentClass.init() }
  }

  func configureLayout(component: Component) {
    let top: CGFloat = component.meta("insetTop", 0.0)
    let left: CGFloat = component.meta("insetLeft", 0.0)
    let bottom: CGFloat = component.meta("insetBottom", 0.0)
    let right: CGFloat = component.meta("insetRight", 0.0)

    render().contentInsets = NSEdgeInsets(top: top, left: left, bottom: bottom, right: right)
  }

  public func deselect() {
    tableView.deselectAll(nil)
  }

  public func selectFirst() -> Self {
    guard let viewModel = item(0) where !component.items.isEmpty else { return self }
    tableView.selectRowIndexes(NSIndexSet(index: 0), byExtendingSelection: false)
    spotsDelegate?.spotDidSelectItem(self, item: viewModel)

    return self
  }
}
