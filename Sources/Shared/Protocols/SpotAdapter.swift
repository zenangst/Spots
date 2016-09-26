import Foundation
import Brick

public protocol SpotAdapter: class {

  /// Resolve a UI component at index
  func ui<T>(atIndex index: Int) -> T?
  /// Append a view model to a Spotable object
  func append(item: Item, withAnimation animation: SpotsAnimation, completion: Completion)
  /// Append a collection of view models to Spotable object
  func append(items: [Item], withAnimation animation: SpotsAnimation, completion: Completion)
  /// Prepend view models to a Spotable object
  func prepend(items: [Item], withAnimation animation: SpotsAnimation, completion: Completion)
  /// Insert view model to a Spotable object
  func insert(item: Item, index: Int, withAnimation animation: SpotsAnimation, completion: Completion)
  /// Update view model to a Spotable object
  func update(item: Item, index: Int, withAnimation animation: SpotsAnimation, completion: Completion)
  /// Delete view model from a Spotable object
  func delete(item: Item, withAnimation animation: SpotsAnimation, completion: Completion)
  /// Delete a collection of view models from a Spotable object
  func delete(item: [Item], withAnimation animation: SpotsAnimation, completion: Completion)
  /// Delete view model at index with animation from a Spotable object
  func delete(index: Int, withAnimation animation: SpotsAnimation, completion: Completion)
  /// Delete view model indexes with animation from a Spotable object
  func delete(indexes: [Int], withAnimation animation: SpotsAnimation, completion: Completion)
  /// Reload view model indexes with animation in a Spotable object
  func reload(indexes: [Int]?, withAnimation animation: SpotsAnimation, completion: Completion)
  /// Reload view model with a change set
  func reloadIfNeeded(changes: ItemChanges, withAnimation animation: SpotsAnimation, updateDataSource: () -> Void, completion: Completion)
}
