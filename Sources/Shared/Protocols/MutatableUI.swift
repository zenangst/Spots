import Brick

/// A protocol used for composition inside Spotable objects
public protocol MutatableUI: class {

  func insert(_ indexes: [Int], withAnimation animation: Animation, completion: (() -> Void)?)

  func reload(_ indexes: [Int], withAnimation animation: Animation, completion: (() -> Void)?)

  func delete(_ indexes: [Int], withAnimation animation: Animation, completion: (() -> Void)?)

  func process(_ changes: (insertions: [Int], reloads: [Int], deletions: [Int]),
               withAnimation animation: Animation,
               updateDataSource: () -> Void,
               completion: ((()) -> Void)?)

  func reloadSection(_ section: Int, withAnimation animation: Animation, completion: (() -> Void)?)

  func beginUpdates()
  func endUpdates()
  func view<T>(at index: Int) -> T?
  func reloadDataSource()
}

extension TableView : MutatableUI {}
extension CollectionView : MutatableUI {}
