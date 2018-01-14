import UIKit

private extension Delegate {
  /// Sets the initial values to the focus delegate.
  /// See `updateFocusDelegate(_ index: Int, _ userInterface: UserInterface)` for more details.
  ///
  /// - Parameter scrollView: The scrollview that is currently in focus, can either be a `UICollectionView`
  ///                         or a `UITableView`.
  func setInitialValuesToFocusDelegate(_ scrollView: ScrollView) {
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
  func updateFocusDelegate(_ index: Int, _ userInterface: UserInterface) {
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
}

extension Delegate: UICollectionViewDelegate {

  public func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
    return component?.model.layout.infiniteScrolling == true
      ? manualFocusCell
      : nil
  }

  /// Asks the delegate for the size of the specified item’s cell.
  ///
  /// - parameter collectionView: The collection view object displaying the flow layout.
  /// - parameter collectionViewLayout: The layout object requesting the information.
  /// - parameter indexPath: The index path of the item.
  ///
  /// - returns: The width and height of the specified item. Both values must be greater than 0.
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let indexPath = indexPathManager.computeIndexPath(indexPath)
    let sizeForItem = resolveComponent({ component in
      component.sizeForItem(at: indexPath)
    }, fallback: .zero)

    return sizeForItem
  }

  /// Tells the delegate that the item at the specified index path was selected.
  ///
  /// - parameter collectionView: The collection view object that is notifying you of the selection change.
  /// - parameter indexPath: The index path of the cell that was selected.
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let indexPath = indexPathManager.computeIndexPath(indexPath)
    resolveComponentItem(at: indexPath) { component, item in
      component.delegate?.component(component, itemSelected: item)
    }
  }

  /// Tells the delegate that the specified cell is about to be displayed in the collection view.
  ///
  /// - parameter collectionView: The collection view object that is adding the cell.
  /// - parameter cell: The cell object being added.
  /// - parameter indexPath: The index path of the data item that the cell represents.
  public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    let indexPath = indexPathManager.computeIndexPath(indexPath)
    resolveComponentItem(at: indexPath) { component, item in
      let view = (cell as? Wrappable)?.wrappedView ?? cell

      if let itemConfigurable = view as? ItemConfigurable {
        component.configure?(itemConfigurable)
      }

      component.delegate?.component(component, willDisplay: view, item: item)
    }
  }

  /// Tells the delegate that the specified cell was removed from the collection view.
  ///
  /// - parameter collectionView: The collection view object that removed the cell.
  /// - parameter cell: The cell object that was removed.
  /// - parameter indexPath: The index path of the data item that the cell represented.
  public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    let indexPath = indexPathManager.computeIndexPath(indexPath)
    resolveComponentItem(at: indexPath) { (component, item) in
      let view = (cell as? Wrappable)?.wrappedView ?? cell
      component.delegate?.component(component, didEndDisplaying: view, item: item)
    }
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
      updateFocusDelegate(manualFocusCell.item, collectionView)

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

    currentlyFocusedItem = manualFocusCell.item
    collectionView.setNeedsFocusUpdate()
  }

  enum JumpDirection {
    case forward
    case backward
  }

  func jump(_ direction: JumpDirection, indexPath: IndexPath, collectionView: UICollectionView) {
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

    manualFocusCell = newIndexPath

    collectionView.setContentOffset(CGPoint(x: currentOffset + jumpOffset,
                                            y: collectionView.contentOffset.y),
                                    animated: false)
  }

  func jump(with context: UICollectionViewFocusUpdateContext, collectionView: UICollectionView, indexPath: IndexPath) {
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

    manualFocusCell = IndexPath(item: currentlyFocusedItem, section: 0)
  }
}

extension Delegate: UITableViewDelegate {

  /// Asks the delegate for the height to use for the header of a particular section.
  ///
  /// - parameter tableView: The table-view object requesting this information.
  /// - parameter heightForHeaderInSection: An index number identifying a section of tableView.
  ///
  /// - returns: Returns the `headerHeight` found in `model.meta`, otherwise 0.0.
  public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return component?.headerHeight ?? 0.0
  }

  public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return component?.footerHeight ?? 0.0
  }

  /// Tells the delegate that the specified row is now selected.
  ///
  /// - parameter tableView: A table-view object informing the delegate about the new row selection.
  /// - parameter indexPath: An index path locating the new selected row in tableView.
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    #if os(iOS)
      tableView.deselectRow(at: indexPath, animated: true)
    #endif

    resolveComponentItem(at: indexPath) { component, item in
      component.delegate?.component(component, itemSelected: item)
    }
  }

  /// Tells the delegate the table view is about to draw a cell for a particular row.
  ///
  /// - Parameters:
  ///   - tableView: The table-view object informing the delegate of this impending event.
  ///   - cell: A table-view cell object that tableView is going to use when drawing the row.
  ///   - indexPath: An index path locating the row in tableView.
  public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    resolveComponentItem(at: indexPath) { (component, item) in
      let view = (cell as? Wrappable)?.wrappedView ?? cell

      if let itemConfigurable = view as? ItemConfigurable {
        component.configure?(itemConfigurable)
      }

      component.delegate?.component(component, willDisplay: view, item: item)
    }
  }

  /// Tells the delegate that the specified cell was removed from the table.
  ///
  /// - parameter tableView: The table-view object that removed the view.
  /// - parameter cell: The cell that was removed.
  /// - parameter indexPath: The index path of the cell.
  public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    resolveComponentItem(at: indexPath) { (component, item) in
      let view = (cell as? Wrappable)?.wrappedView ?? cell
      component.delegate?.component(component, didEndDisplaying: view, item: item)
    }
  }

  public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return component?.headerView ?? nil
  }

  public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return component?.footerView ?? nil
  }

  @available(iOS 9.0, *)
  public func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool {
    guard let indexPath = context.nextFocusedIndexPath else {
      return true
    }

    updateFocusDelegate(indexPath.item, tableView)

    return true
  }

  @available(iOS 9.0, *)
  public func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
    setInitialValuesToFocusDelegate(tableView)
  }

  /// Asks the delegate for the height to use for a row in a specified location.
  ///
  /// - parameter tableView: The table-view object requesting this information.
  /// - parameter indexPath: An index path that locates a row in tableView.
  ///
  /// - returns:  A nonnegative floating-point value that specifies the height (in points) that row should be based on the view model height, defaults to 0.0.
  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let heightForRow: CGFloat = resolveComponent({ component in
      component.model.size = CGSize(
        width: tableView.frame.size.width,
        height: tableView.frame.size.height)

      return component.item(at: indexPath)?.size.height ?? 0
    }, fallback: 0.0)

    return heightForRow
  }
}

extension Delegate: UICollectionViewDelegateFlowLayout {

  /// Asks the delegate for the spacing between successive rows or columns of a section.
  ///
  /// - parameter collectionView:       The collection view object displaying the flow layout.
  /// - parameter collectionViewLayout: The layout object requesting the information.
  /// - parameter section:              The index number of the section whose line spacing is needed.
  /// - returns: The minimum space (measured in points) to apply between successive lines in a section.
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    if let layout = collectionView.flowLayout {
      return layout.minimumLineSpacing
    } else {
      return 0
    }
  }

  /// Asks the delegate for the margins to apply to content in the specified section.
  ///
  /// - parameter collectionView:       The collection view object displaying the flow layout.
  /// - parameter collectionViewLayout: The layout object requesting the information.
  /// - parameter section:              The index number of the section whose insets are needed.
  ///
  /// - returns: The margins to apply to items in the section.
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    if let layout = collectionView.flowLayout {
      guard layout.scrollDirection == .horizontal else {
        return layout.sectionInset
      }

      let left = layout.minimumLineSpacing / 2
      let right = layout.minimumLineSpacing / 2

      return UIEdgeInsets(top: layout.sectionInset.top,
                          left: left,
                          bottom: layout.sectionInset.bottom,
                          right: right)
    } else {
      return UIEdgeInsets.zero
    }
  }
}
