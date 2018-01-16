import Foundation

final class IndexPathManager {
  weak private var component: Component?

  init(component: Component) {
    self.component = component
  }

  func computeIndexPath(_ indexPath: IndexPath) -> IndexPath {
    guard let component = component,
      let dataSource = component.componentDataSource,
      component.model.layout.infiniteScrolling,
      component.model.items.count >= dataSource.buffer else {
        return indexPath
    }

    let index = indexPath.item
    let wrapped = (index - dataSource.buffer < 0)
      ? (component.model.items.count + (index - dataSource.buffer))
      : (index - dataSource.buffer)
    let adjustedIndex = wrapped % component.model.items.count
    return IndexPath(item: adjustedIndex, section: 0)
  }
}
