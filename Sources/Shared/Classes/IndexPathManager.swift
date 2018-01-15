import Foundation

final class IndexPathManager {
  weak private var component: Component?

  init(component: Component) {
    self.component = component
  }

  func computeIndexPath(_ indexPath: IndexPath) -> IndexPath {
    guard let component = component, component.model.layout.infiniteScrolling else {
      return indexPath
    }

    let buffer = component.componentDataSource?.buffer ?? 2
    let count = component.model.items.count
    let index = indexPath.item
    let wrapped = (index - buffer < 0) ? (count + (index - buffer)) : (index - buffer)
    let adjustedIndex = wrapped % count
    return IndexPath(item: adjustedIndex, section: 0)
  }
}
