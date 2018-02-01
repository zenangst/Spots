import UIKit

extension Delegate {
  // MARK: - UICollectionView

  public func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
    return component?.model.layout.infiniteScrolling == true
      ? manualFocusedIndexPath
      : nil
  }

  /// Asks the delegate whether the item at the specified index path can be focused.
  ///
  /// - parameter collectionView: The collection view object requesting this information.
  /// - parameter indexPath:      The index path of an item in the collection view.
  ///
  /// - returns: YES if the item can receive be focused or NO if it can not.
  public func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
    if let initialFocusedIndexPath = initialFocusedIndexPath {
      return initialFocusedIndexPath == indexPath
    } else {
      let indexPath = indexPathManager.computeIndexPath(indexPath)
      let canFocusItem = resolveComponent({ component in
        return component.item(at: indexPath) != nil
      }, fallback: false)
      return canFocusItem
    }
  }

  ///Asks the delegate whether a change in focus should occur.
  ///
  /// - parameter collectionView: The collection view object requesting this information.
  /// - parameter context:        The context object containing metadata associated with the focus change.
  /// This object contains the index path of the previously focused item and the item targeted to receive focus next. Use this information to determine if the focus change should occur.
  ///
  /// - returns: YES if the focus change should occur or NO if it should not.
  @available(iOS 9.0, *)
  public func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
    guard let indexPath = context.nextFocusedIndexPath else {
      return true
    }

    let computedIndexPath = indexPathManager.computeIndexPath(indexPath)

    if let component = component, component.model.layout.infiniteScrolling == true {
      let count = component.model.items.count
      let buffer = (collectionView.dataSource as? DataSource)?.buffer ?? 0
      updateFocusDelegate(computedIndexPath.item, collectionView)

      if context.focusHeading == .left && indexPath.item < buffer {
        hasReachedBuffer = true
        modifyManualFocusedIndexPath(with: context, collectionView: collectionView, indexPath: indexPath)
        return true
      }

      if context.focusHeading == .right && indexPath.item >= buffer + count {
        hasReachedBuffer = true
        modifyManualFocusedIndexPath(with: context, collectionView: collectionView, indexPath: indexPath)
        return true
      }
    } else {
      updateFocusDelegate(computedIndexPath.item, collectionView)
    }

    return context.nextFocusedView?.canBecomeFocused ?? false
  }

  @available(iOS 9.0, *)
  public func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
    setInitialValuesToFocusDelegate(collectionView)
    guard let nextFocusedIndexPath = context.nextFocusedIndexPath else {
      return
    }

    if let initialFocusedIndexPath = self.initialFocusedIndexPath {
      self.initialFocusedIndexPath = nil
      modifyContentOffsetFor(context.focusHeading, indexPath: nextFocusedIndexPath, collectionView: collectionView)
      collectionView.setNeedsFocusUpdate()
    } else if hasReachedBuffer {
      hasReachedBuffer = false
      modifyContentOffsetFor(context.focusHeading, indexPath: nextFocusedIndexPath, collectionView: collectionView)
      collectionView.setNeedsFocusUpdate()
    }
  }

  // MARK: - UITableView

  @available(iOS 9.0, *)
  public func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
    setInitialValuesToFocusDelegate(tableView)
  }

  @available(iOS 9.0, *)
  public func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool {
    guard let indexPath = context.nextFocusedIndexPath else {
      return true
    }

    updateFocusDelegate(indexPath.item, tableView)

    return true
  }

  // MARK: - Private methods

  /// Sets the initial values to the focus delegate.
  /// See `updateFocusDelegate(_ index: Int, _ userInterface: UserInterface)` for more details.
  ///
  /// - Parameter scrollView: The scrollview that is currently in focus, can either be a `UICollectionView`
  ///                         or a `UITableView`.
  private func setInitialValuesToFocusDelegate(_ scrollView: ScrollView) {
    if let component = component,
      component.view == scrollView,
      component.focusDelegate?.focusedComponent == nil {
      let focusedIndex = component.focusDelegate?.focusedItemIndex ?? 0
      component.focusDelegate?.focusedComponent = component
      component.focusDelegate?.focusedView = component.userInterface?.view(at: focusedIndex)
    }
  }

  /// Sets new properties to the focus delegate.
  /// The properties that gets updated are `.focusedComponent`, `focusedItemIndex` and `focusedView`.
  /// `.focusedComponent` only gets set if the current focused component is different than the current one.
  /// This is done to only trigger the observation once.
  ///
  /// - Parameters:
  ///   - index: The index of the current view that is selected.
  ///   - userInterface: The user interface that is currently in focus, can either be a `UICollectionView`
  ///                    or a `UITableView`.
  private func updateFocusDelegate(_ index: Int, _ userInterface: UserInterface) {
    if let component = component, index < component.model.items.count {
      if component.focusDelegate?.focusedComponent != component {
        component.focusDelegate?.focusedComponent = component
      }
      component.focusDelegate?.focusedItemIndex = index
      component.focusDelegate?.focusedView = userInterface.view(at: index)
      component.focusGuide.preferredFocusedView = userInterface.view(at: index)
    }
  }

  private func modifyContentOffsetFor(_ heading: UIFocusHeading, indexPath: IndexPath, collectionView: UICollectionView) {
    guard let component = component else {
      return
    }

    var shouldRemoveOffset: Bool = false

    var newIndexPath = indexPath
    switch heading {
    case .left:
      newIndexPath.item += component.model.items.count
    case .right:
      newIndexPath.item -= component.model.items.count
    default:
      shouldRemoveOffset = true
    }

    let currentOffset = collectionView.contentOffset.x
    let itemSizeIndexPath = indexPathManager.computeIndexPath(newIndexPath)
    let totalWidth = component.sizeForItem(at: itemSizeIndexPath).width + CGFloat(component.model.layout.itemSpacing)
    var additionalOffset = CGFloat(component.model.items.count) * totalWidth

    if case .right = heading {
      additionalOffset *= -1
    } else if shouldRemoveOffset {
      additionalOffset = 0
    }

    manualFocusedIndexPath = newIndexPath

    collectionView.setContentOffset(CGPoint(x: currentOffset + additionalOffset,
                                            y: collectionView.contentOffset.y),
                                    animated: false)
  }

  private func modifyManualFocusedIndexPath(with context: UICollectionViewFocusUpdateContext, collectionView: UICollectionView, indexPath: IndexPath) {
    guard let component = component, context.focusHeading == .left || context.focusHeading == .right else {
      return
    }

    let focusHeading = context.focusHeading
    let count = component.model.items.count
    let buffer = component.componentDataSource?.buffer ?? 0

    var newFocusedIndex = indexPath.item

    if focusHeading == .left && indexPath.item < buffer {
      newFocusedIndex += count
    }

    if focusHeading == .right && indexPath.item >= buffer + count {
      newFocusedIndex -= count
    }

    manualFocusedIndexPath = IndexPath(item: newFocusedIndex, section: 0)
  }
}
