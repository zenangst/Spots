import UIKit

extension Delegate: UICollectionViewDelegate {

  /// Asks the delegate for the size of the specified item’s cell.
  ///
  /// - parameter collectionView: The collection view object displaying the flow layout.
  /// - parameter collectionViewLayout: The layout object requesting the information.
  /// - parameter indexPath: The index path of the item.
  ///
  /// - returns: The width and height of the specified item. Both values must be greater than 0.
  @objc(collectionView:layout:sizeForItemAtIndexPath:) public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    guard let component = component else { return CGSize.zero }

    return component.sizeForItem(at: indexPath)
  }

  /// Tells the delegate that the item at the specified index path was selected.
  ///
  /// - parameter collectionView: The collection view object that is notifying you of the selection change.
  /// - parameter indexPath: The index path of the cell that was selected.
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let component = component, let item = component.item(at: indexPath) else { return }
    component.delegate?.component(component, itemSelected: item)
  }

  /// Tells the delegate that the specified cell is about to be displayed in the collection view.
  ///
  /// - parameter collectionView: The collection view object that is adding the cell.
  /// - parameter cell: The cell object being added.
  /// - parameter indexPath: The index path of the data item that the cell represents.
  public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    guard let component = component, let item = component.item(at: indexPath) else {
      return
    }

    component.delegate?.component(component, willDisplay: cell, item: item)
  }

  /// Tells the delegate that the specified cell was removed from the collection view.
  ///
  /// - parameter collectionView: The collection view object that removed the cell.
  /// - parameter cell: The cell object that was removed.
  /// - parameter indexPath: The index path of the data item that the cell represented.
  public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    guard let component = component, indexPath.item < component.items.count,
      let item = component.item(at: indexPath) else {
      return
    }

    component.delegate?.component(component, didEndDisplaying: cell, item: item)
  }

  /// Asks the delegate whether the item at the specified index path can be focused.
  ///
  /// - parameter collectionView: The collection view object requesting this information.
  /// - parameter indexPath:      The index path of an item in the collection view.
  ///
  /// - returns: YES if the item can receive be focused or NO if it can not.
  public func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
    guard let component = component, let _ = component.item(at: indexPath) else {
      return  false
    }
    return true
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

    if let component = component,
      component.items[indexPath.item].kind != "composite",
      indexPath.item < component.items.count {
      component.focusDelegate?.focusedSpot = component
      component.focusDelegate?.focusedItemIndex = indexPath.item
    }

    return !indexPath.isEmpty
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
    guard let component = component else {
      return 0.0
    }

    let kind: String = component.model.header?.kind ?? ""
    let header = component.type.headers.make(kind)

    if header == nil {
      let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: kind)
      view?.frame.size.height = component.model.meta(ListComponent.Key.headerHeight, 0.0)
      view?.frame.size.width = tableView.frame.size.width

      switch view {
      case let view as ListHeaderFooterWrapper:
        if let (_, resolvedView) = Configuration.views.make(kind),
          let componentView = resolvedView as? ItemConfigurable {
          view.frame.size.height = componentView.preferredViewSize.height
        }
      case let view as ItemConfigurable:
        if var item = component.model.header {
          view.configure(&item)
          component.model.header = item
        }
      default:
        break
      }

      return view?.frame.size.height ?? 0.0
    }

    return (header?.view as? ItemConfigurable)?.preferredViewSize.height ?? 0.0
  }

  public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    guard let component = component else {
      return 0.0
    }

    let kind: String = component.model.header?.kind ?? ""
    let header = component.type.headers.make(kind)

    if header == nil {
      let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: kind)
      view?.frame.size.height = component.model.meta(ListComponent.Key.headerHeight, 0.0)
      view?.frame.size.width = tableView.frame.size.width

      switch view {
      case let view as ListHeaderFooterWrapper:
        if let (_, resolvedView) = Configuration.views.make(kind),
          let componentView = resolvedView as? ItemConfigurable {
            view.frame.size.height = componentView.preferredViewSize.height
        }
      case let view as ItemConfigurable:
        if var item = component.model.footer {
          view.configure(&item)
          component.model.footer = item
        }
      default:
        break
      }

      return view?.frame.size.height ?? 0.0
    }

    return (header?.view as? ItemConfigurable)?.preferredViewSize.height ?? 0.0
  }

  /// Asks the data source for the title of the header of the specified section of the table view.
  ///
  /// - parameter tableView: The table-view object asking for the title.
  /// - parameter section: An index number identifying a section of tableView.
  ///
  /// - returns: A string to use as the title of the section header. Will return `nil` if title is not present on ComponentModel
  @nonobjc public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    guard let component = component else {
      return nil
    }

    let kind: String = component.model.header?.kind ?? ""
    guard component.type.headers.make(kind) == nil else {
      return nil
    }

    return !component.model.title.isEmpty ? component.model.title : nil
  }

  /// Tells the delegate that the specified row is now selected.
  ///
  /// - parameter tableView: A table-view object informing the delegate about the new row selection.
  /// - parameter indexPath: An index path locating the new selected row in tableView.
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    #if os(iOS)
      tableView.deselectRow(at: indexPath, animated: true)
    #endif
    if let component = component, let item = component.item(at: indexPath) {
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
    guard let component = component, let item = component.item(at: indexPath) else {
      return
    }

    component.delegate?.component(component, willDisplay: cell, item: item)
  }

  /// Tells the delegate that the specified cell was removed from the table.
  ///
  /// - parameter tableView: The table-view object that removed the view.
  /// - parameter cell: The cell that was removed.
  /// - parameter indexPath: The index path of the cell.
  public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard let component = component, let item = component.item(at: indexPath) else {
      return
    }

    component.delegate?.component(component, didEndDisplaying: cell, item: item)
  }

  /// Asks the delegate for a view object to display in the header of the specified section of the table view.
  ///
  /// - parameter tableView: The table-view object asking for the view object.
  /// - parameter section: An index number identifying a section of tableView.
  ///
  /// - returns: A view object to be displayed in the header of section based on the kind of the ListComponent and registered headers.
  public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let component = component,
      let kind = component.model.header?.kind else {
        return nil
    }

    let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: kind)
    view?.frame.size.height = component.model.meta(ListComponent.Key.headerHeight, 0.0)
    view?.frame.size.width = tableView.frame.size.width

    switch view {
      case let view as ListHeaderFooterWrapper:
      if let (_, resolvedView) = Configuration.views.make(kind),
        let customView = resolvedView {
        view.configure(with: customView)

        if let componentView = customView as? ItemConfigurable {
          customView.frame.size = view.frame.size
          if var item = component.model.header {
            customView.frame.size.height = componentView.preferredViewSize.height
            componentView.configure(&item)
            component.model.header = item
          }
        }
      }
      case let view as ItemConfigurable:
        if var item = component.model.header {
          view.configure(&item)
          component.model.header = item
        }
      default:
        break
    }

    return view
  }

  public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    guard let component = component,
      let kind = component.model.footer?.kind else {
        return nil
    }

    let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: kind)
    view?.frame.size.height = component.model.meta(ListComponent.Key.headerHeight, 0.0)
    view?.frame.size.width = tableView.frame.size.width

    switch view {
    case let view as ListHeaderFooterWrapper:
      if let (_, resolvedView) = Configuration.views.make(kind),
        let customView = resolvedView {
        view.configure(with: customView)

        if let componentView = customView as? ItemConfigurable {
          customView.frame.size = view.frame.size
          if var item = component.model.footer {
            customView.frame.size.height = componentView.preferredViewSize.height
            componentView.configure(&item)
            component.model.footer = item
          }
        }
      }
    case let view as ItemConfigurable:
      if var item = component.model.footer {
        view.configure(&item)
        component.model.footer = item
      }
    default:
      break
    }

    return view
  }

  @available(iOS 9.0, *)
  public func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool {
    guard let indexPath = context.nextFocusedIndexPath else {
      return true
    }

    if let component = component,
      component.items[indexPath.item].kind != "composite",
      indexPath.item < component.items.count {
      component.focusDelegate?.focusedSpot = component
      component.focusDelegate?.focusedItemIndex = indexPath.item
    }

    return true
  }

  /// Asks the delegate for the height to use for a row in a specified location.
  ///
  /// - parameter tableView: The table-view object requesting this information.
  /// - parameter indexPath: An index path that locates a row in tableView.
  ///
  /// - returns:  A nonnegative floating-point value that specifies the height (in points) that row should be based on the view model height, defaults to 0.0.
  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    guard let component = component else {
      return 0.0
    }

    component.model.size = CGSize(
      width: tableView.frame.size.width,
      height: tableView.frame.size.height)

    return component.item(at: indexPath)?.size.height ?? 0
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
    if let layout = collectionView.collectionViewLayout as? GridableLayout {
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
    if let layout = collectionView.collectionViewLayout as? GridableLayout {
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
