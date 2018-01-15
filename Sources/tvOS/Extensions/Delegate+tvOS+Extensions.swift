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
    let indexPath = indexPathManager.computeIndexPath(indexPath)
    let canFocusItem = resolveComponent({ component in
      return component.item(at: indexPath) != nil
    }, fallback: false)
    return canFocusItem
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

    if let component = component, component.model.layout.infiniteScrolling == true {
      let count = component.model.items.count
      let buffer = (collectionView.dataSource as? DataSource)?.buffer ?? 0
      let computedIndexPath = indexPathManager.computeIndexPath(indexPath)
      updateFocusDelegate(computedIndexPath.item, collectionView)

      if context.focusHeading == .left && indexPath.item < buffer {
        navigating = true
        jump(with: context, collectionView: collectionView, indexPath: indexPath)
        return true
      }

      if context.focusHeading == .right && indexPath.item >= buffer + count {
        navigating = true
        jump(with: context, collectionView: collectionView, indexPath: indexPath)
        return true
      }
    } else {
      updateFocusDelegate(indexPath.item, collectionView)
    }

    return context.nextFocusedView?.canBecomeFocused ?? false
  }

  @available(iOS 9.0, *)
  public func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
    setInitialValuesToFocusDelegate(collectionView)
    guard let nextFocusedIndexPath = context.nextFocusedIndexPath, navigating else {
      return
    }

    navigating = false

    if context.focusHeading == .left {
      jump(.forward, indexPath: nextFocusedIndexPath, collectionView: collectionView)
    } else {
      jump(.backward, indexPath: nextFocusedIndexPath, collectionView: collectionView)
    }

    currentlyFocusedItem = manualFocusedIndexPath.item
    collectionView.setNeedsFocusUpdate()
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

    #if os(tvOS)
      updateFocusDelegate(indexPath.item, tableView)
    #endif

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
      #if os(tvOS)
        component.focusGuide.preferredFocusedView = userInterface.view(at: index)
      #endif
    }
  }

  private enum JumpDirection {
    case forward
    case backward
  }

  private func jump(_ direction: JumpDirection, indexPath: IndexPath, collectionView: UICollectionView) {
    guard let component = component else {
      return
    }

    var newIndexPath = indexPath
    switch direction {
    case .forward:
      newIndexPath.item += component.model.items.count
    case .backward:
      newIndexPath.item -= component.model.items.count
    }

    let currentOffset = collectionView.contentOffset.x
    let itemSizeIndexPath = indexPathManager.computeIndexPath(newIndexPath)
    let totalWidth = component.sizeForItem(at: itemSizeIndexPath).width + CGFloat(component.model.layout.itemSpacing)
    var jumpOffset = CGFloat(component.model.items.count) * totalWidth
    if case .backward = direction {
      jumpOffset *= -1
    }

    manualFocusedIndexPath = newIndexPath

    collectionView.setContentOffset(CGPoint(x: currentOffset + jumpOffset,
                                            y: collectionView.contentOffset.y),
                                    animated: false)
  }

  private func jump(with context: UICollectionViewFocusUpdateContext, collectionView: UICollectionView, indexPath: IndexPath) {
    guard context.focusHeading == .left || context.focusHeading == .right else {
      return
    }

    let focusHeading = context.focusHeading
    let count = component!.model.items.count
    let buffer = component!.componentDataSource?.buffer ?? 0

    currentlyFocusedItem = indexPath.item

    if focusHeading == .left && indexPath.item < buffer {
      currentlyFocusedItem += count
    }

    if focusHeading == .right && indexPath.item >= buffer + count {
      currentlyFocusedItem -= count
    }

    manualFocusedIndexPath = IndexPath(item: currentlyFocusedItem, section: 0)
  }
}
