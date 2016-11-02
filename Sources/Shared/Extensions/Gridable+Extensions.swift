#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif
import Brick

/// A Spotable extension for Gridable objects
public extension Spotable where Self : Gridable {

  #if os(OSX)
  /// Return collection view as a scroll view
  ///
  /// - returns: Returns a UICollectionView as a UIScrollView
  ///
  public func render() -> CollectionView {
    return collectionView
  }
  #else
  /// Return collection view as a scroll view
  ///
  /// - returns: Returns a UICollectionView as a UIScrollView
  ///
  public func render() -> ScrollView {
    return collectionView
  }
  #endif

  /// Setup Spotable component with base size
  ///
  /// - parameter size: The size of the superview
  public func setup(_ size: CGSize) {
    collectionView.frame.size.width = size.width
    #if !os(OSX)
      GridSpot.configure?(collectionView, layout)

      if let resolve = type(of: self).headers.make(component.header),
        let view = resolve.view as? Componentable,
        !component.header.isEmpty {

        layout.headerReferenceSize.width = collectionView.frame.size.width
        layout.headerReferenceSize.height = view.frame.size.height

        if layout.headerReferenceSize.width == 0.0 {
          layout.headerReferenceSize.width = size.width
        }

        if layout.headerReferenceSize.height == 0.0 {
          layout.headerReferenceSize.height = view.preferredHeaderHeight
        }
      }
      collectionView.frame.size.height = layout.contentSize.height
    #endif
    layout.prepare()
    component.size = collectionView.frame.size
  }

  /// Layout with size
  ///
  /// - parameter size: A CGSize to set the width and height of the collection view
  public func layout(_ size: CGSize) {
    layout.invalidateLayout()
    collectionView.frame.size.width = size.width
  }

  /// Process updates and determine if the updates are done.
  ///
  /// - parameter updates:    A collection of updates.
  /// - parameter animation:  A Animation that is used when performing the mutation.
  /// - parameter completion: A completion closure that is run when the updates are finished.
  public func process(_ updates: [Int], withAnimation animation: Animation, completion: Completion) {
    guard !updates.isEmpty else {
      completion?()
      return
    }

    let lastUpdate = updates.last
    for index in updates {
      guard let item = self.item(at: index) else { completion?(); continue }
      self.update(item, index: index, withAnimation: animation) {
        if index == lastUpdate {
          completion?()
        }
      }
    }
  }

  /// Reload spot with ItemChanges.
  ///
  /// - parameter changes:          A collection of changes; inserations, updates, reloads, deletions and updated children.
  /// - parameter animation:        A Animation that is used when performing the mutation.
  /// - parameter updateDataSource: A closure to update your data source.
  /// - parameter completion:       A completion closure that runs when your updates are done.
  public func reloadIfNeeded(_ changes: ItemChanges, withAnimation animation: Animation = .automatic, updateDataSource: () -> Void, completion: Completion) {
    collectionView.process((insertions: changes.insertions, reloads: changes.reloads, deletions: changes.deletions), updateDataSource: updateDataSource) {
      if changes.updates.isEmpty {
        self.process(changes.updatedChildren, withAnimation: animation) {
          self.layout(self.collectionView.bounds.size)
          completion?()
        }
      } else {
        self.process(changes.updates, withAnimation: animation) {
          self.process(changes.updatedChildren, withAnimation: animation) {
            self.layout(self.collectionView.bounds.size)
            completion?()
          }
        }
      }
    }
  }
}
