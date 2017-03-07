import UIKit

extension DataSource {

  func prepareWrappableView(_ view: Wrappable, atIndex index: Int, in spot: Spotable, parentFrame: CGRect = CGRect.zero) {
    if let (_, customView) = Configuration.views.make(spot.model.items[index].kind, parentFrame: parentFrame),
      let wrappedView = customView {
      view.configure(with: wrappedView)

      if let configurableView = customView as? ItemConfigurable {
        configurableView.configure(&spot.model.items[index])

        if spot.model.items[index].size.height == 0.0 {
          spot.model.items[index].size = configurableView.preferredViewSize
        }

        spot.configure?(configurableView)
      } else {
        spot.model.items[index].size.height = wrappedView.frame.size.height
      }
    }
  }

  func prepareComposableView(_ view: Composable, atIndex index: Int, in spot: Spotable) {
    let compositeSpots = spot.compositeSpots.filter({ $0.itemIndex == index })
    view.configure(&spot.model.items[index], compositeSpots: compositeSpots)
  }

  func prepareItemConfigurableView(_ view: ItemConfigurable, atIndex index: Int, in spot: Spotable) {
    view.configure(&spot.model.items[index])

    if spot.model.items[index].size.height == 0.0 {
      spot.model.items[index].size = view.preferredViewSize
    }

    spot.configure?(view)
  }
}

extension DataSource: UICollectionViewDataSource {

  /// Asks the data source for the number of items in the specified section. (required)
  ///
  /// - parameter collectionView: An object representing the collection view requesting this information.
  /// - parameter section:        An index number identifying a section in collectionView. This index value is 0-based.
  ///
  /// - returns: The number of rows in section.
  @available(iOS 6.0, *)
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    guard let spot = spot else {
      return 0
    }

    return spot.model.items.count
  }

  /// Asks your data source object to provide a supplementary view to display in the collection view.
  /// A configured supplementary view object. You must not return nil from this method.
  ///
  /// - parameter collectionView: The collection view requesting this information.
  /// - parameter kind:           The kind of supplementary view to provide. The value of this string is defined by the layout object that supports the supplementary view.
  /// - parameter indexPath:      The index path that specifies the location of the new supplementary view.
  ///
  /// - returns: A configured supplementary view object.
  public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    guard let spot = spot,
      let collectionViewLayout = collectionView.collectionViewLayout as? GridableLayout,
      !kind.isEmpty else {
        return UICollectionReusableView()
    }

    let identifier: String
    var viewHeight: CGFloat = 0.0

    switch kind {
    case UICollectionElementKindSectionHeader:
      if spot.model.header.isEmpty {
        identifier = spot.type.headers.defaultIdentifier
      } else {
        identifier = spot.model.header
      }
      viewHeight = collectionViewLayout.headerReferenceSize.height
    case UICollectionElementKindSectionFooter:
      identifier = spot.model.footer
      viewHeight = collectionViewLayout.footerHeight
    default:
      return UICollectionReusableView()
    }

    let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                               withReuseIdentifier: identifier,
                                                               for: indexPath)

    switch view {
    case let view as GridHeaderFooterWrapper:
      if let (_, resolvedView) = Configuration.views.make(identifier),
        let customView = resolvedView {
        view.configure(with: customView)
        view.frame.size.height = viewHeight
        view.frame.size.width = collectionView.frame.size.width

        (customView as? Componentable)?.configure(spot.model)
      }
    case let view as Componentable:
      view.configure(spot.model)
    default:
      break
    }

    return view
  }

  /// Asks the data source for the number of items in the specified section. (required)
  ///
  /// - parameter collectionView: An object representing the collection view requesting this information.
  /// - parameter section:        An index number identifying a section in collectionView. This index value is 0-based.
  ///
  /// - returns: The number of rows in section.
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let spot = spot, indexPath.item < spot.model.items.count else {
      return UICollectionViewCell()
    }

    spot.model.items[indexPath.item].index = indexPath.item

    let reuseIdentifier = spot.identifier(at: indexPath)
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                  for: indexPath)

    switch cell {
    case let cell as GridWrapper:
      prepareWrappableView(cell, atIndex: indexPath.item, in: spot, parentFrame: cell.bounds)
    case let cell as Composable:
      prepareComposableView(cell, atIndex: indexPath.item, in: spot)
    case let cell as ItemConfigurable:
      prepareItemConfigurableView(cell, atIndex: indexPath.item, in: spot)
    default:
      break
    }

    return cell
  }
}

extension DataSource: UITableViewDataSource {

  /// Tells the data source to return the number of rows in a given section of a table view. (required)
  ///
  /// - parameter tableView: The table-view object requesting this information.
  /// - parameter section: An index number identifying a section in tableView.
  ///
  /// - returns: The number of rows in section.
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let spot = spot else {
      return 0
    }

    return spot.model.items.count
  }

  /// Asks the data source for a cell to insert in a particular location of the table view. (required)
  ///
  /// - parameter tableView: A table-view object requesting the cell.
  /// - parameter indexPath: An index path locating a row in tableView.
  ///
  /// - returns: An object inheriting from UITableViewCell that the table view can use for the specified row. Will return the default table view cell for the current component based of kind.
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let spot = spot, indexPath.item < spot.model.items.count else {
      return UITableViewCell()
    }

    if indexPath.item < spot.model.items.count {
      spot.model.items[indexPath.item].index = indexPath.row
    }

    let reuseIdentifier = spot.identifier(at: indexPath)
    let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier,
                                                              for: indexPath)

    switch cell {
    case let cell as ListWrapper:
      prepareWrappableView(cell, atIndex: indexPath.item, in: spot, parentFrame: cell.bounds)
    case let cell as Composable:
      prepareComposableView(cell, atIndex: indexPath.row, in: spot)
    case let cell as ItemConfigurable:
      prepareItemConfigurableView(cell, atIndex: indexPath.item, in: spot)
    default:
      break
    }

    return cell
  }
}
