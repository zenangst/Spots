import Cocoa

extension Delegate: NSCollectionViewDelegate {

  public func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
    /*
     This delay is here to avoid an assertion that happens inside the collection view binding,
     it tries to resolve the item at index but it no longer exists so the assertion is thrown.
     This can probably be fixed in a more convenient way in the future without delays.
     */
    Dispatch.after(seconds: 0.1) { [weak self] in
      guard let indexPath = indexPaths.first else {
        return
      }

      self?.resolveComponentItem(at: indexPath) { component, item in
        if component.model.interaction.mouseClick == .single {
          component.delegate?.component(component, itemSelected: item)
        }
      }
    }
  }

  /// Notifies the delegate that the specified item is about to be displayed by the collection view.
  ///
  /// - parameter collectionView: The collection view that is adding the item.
  /// - parameter item: The item being added.
  /// - parameter indexPath: The index path of the item.
  public func collectionView(_ collectionView: NSCollectionView, willDisplay item: NSCollectionViewItem, forRepresentedObjectAt indexPath: IndexPath) {
    resolveComponentItem(at: indexPath) { component, resolvedItem in
      guard let view = (item as? Wrappable)?.wrappedView else {
        return
      }

      if let itemConfigurable = view as? ItemConfigurable {
        component.configure?(itemConfigurable)
      }

      let selectedIndexes: [Int] = collectionView.selectionIndexes.map { $0 }
      if selectedIndexes.contains(indexPath.item) {
        item.isSelected = true
      }
      component.delegate?.component(component, willDisplay: view, item: resolvedItem)
    }
  }

  /// Notifies the delegate that the specified item was removed from the collection view.
  ///
  /// - parameter collectionView: The collection view that removed the item.
  /// - parameter item: The item that was removed.
  /// - parameter indexPath: The index path of the item.
  public func collectionView(_ collectionView: NSCollectionView, didEndDisplaying item: NSCollectionViewItem, forRepresentedObjectAt indexPath: IndexPath) {
    resolveComponentItem(at: indexPath) { component, resolvedItem in
      guard let view = (item as? Wrappable)?.wrappedView else {
        return
      }

      component.delegate?.component(component, didEndDisplaying: view, item: resolvedItem)
    }
  }
}

extension Delegate: NSCollectionViewDelegateFlowLayout {

  public func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
    let sizeForItem = resolveComponent({ $0.sizeForItem(at: indexPath) }, fallback: .zero)
    return sizeForItem
  }
}

extension Delegate: NSTableViewDelegate {

  public func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
    let heightOfRow: CGFloat = resolveComponent({ component in
      component.model.size = CGSize(
        width: tableView.frame.width,
        height: tableView.frame.height)

      let height = row < component.model.items.count
        ? component.item(at: row)?.size.height ?? 0
        : 1.0

      if height == 0 {
        return 1.0
      }

      return height
    }, fallback: 1.0)

    return heightOfRow
  }

  public func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
    guard let component = component, row >= 0 && row < component.model.items.count else {
      return nil
    }

    let reuseIdentifier = component.identifier(at: row)

    guard let viewContainer = Configuration.views.make(reuseIdentifier) else {
      return nil
    }

    var resolvedView: View? = nil
    if let type = viewContainer.type {
      switch type {
      case .regular:
        resolvedView = viewContainer.view
      case .nib:
        resolvedView = tableView.make(withIdentifier: reuseIdentifier, owner: nil)
      }
    }

    switch resolvedView {
    case let item as Wrappable:
      viewPreparer.prepareWrappableView(item, atIndex: row, in: component, parentFrame: item.bounds)
    case let view as NSTableRowView:
      if let itemConfigurable = view as? ItemConfigurable {
        itemConfigurable.configure(with: component.model.items[row])
        component.model.items[row].size.height = itemConfigurable.computeSize(for: component.model.items[row], containerSize: component.view.frame.size).height
        component.configure?(itemConfigurable)
      }
    default:
      if let view = resolvedView, !(view is NSTableRowView) {
        let wrapper = ListWrapper()
        wrapper.configure(with: view)

        if let itemConfigurable = view as? ItemConfigurable {
          itemConfigurable.configure(with: component.model.items[row])
          component.model.items[row].size.height = itemConfigurable.computeSize(for: component.model.items[row], containerSize: view.frame.size).height
          component.configure?(itemConfigurable)
        }

        resolvedView = wrapper
      }
    }

    (resolvedView as? NSTableRowView)?.identifier = reuseIdentifier

    return resolvedView as? NSTableRowView
  }

  public func tableView(_ tableView: NSTableView, willDisplayCell cell: Any, for tableColumn: NSTableColumn?, row: Int) {
    resolveComponent { component in
      guard let item = component.item(at: row),
        let cell = cell as? View else {
          return
      }

      let view = (cell as? Wrappable)?.wrappedView ?? cell
      component.delegate?.component(component, willDisplay: view, item: item)
    }
  }

  public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    return nil
  }
}
