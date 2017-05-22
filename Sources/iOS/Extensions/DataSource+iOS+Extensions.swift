import UIKit

extension DataSource: UICollectionViewDataSource {

  /// Asks the data source for the number of items in the specified section. (required)
  ///
  /// - parameter collectionView: An object representing the collection view requesting this information.
  /// - parameter section:        An index number identifying a section in collectionView. This index value is 0-based.
  ///
  /// - returns: The number of rows in section.
  @available(iOS 6.0, *)
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    guard let component = component, let layout = component.model.layout else {
        return 0
    }

    if layout.infiniteScrolling {
      var additionalIndexes: Int = 0
      var remainingWidth: CGFloat = 0
      for item in component.model.items {
        remainingWidth += item.size.width

        if remainingWidth >= collectionView.frame.size.width {
          break
        }

        additionalIndexes += 1
      }

      return component.model.items.count + additionalIndexes
    }

    return component.model.items.count
  }

  /// Asks the data source for the number of items in the specified section. (required)
  ///
  /// - parameter collectionView: An object representing the collection view requesting this information.
  /// - parameter section:        An index number identifying a section in collectionView. This index value is 0-based.
  ///
  /// - returns: The number of rows in section.
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let component = component,
      let layout = component.model.layout else {
        return UICollectionViewCell()
    }

    let currentIndexPath: IndexPath

    if layout.infiniteScrolling {
      /// Compute the first and last item in the list, it should start with the last
      /// item instead of the first on the model. The last item in the list should
      /// also be resolved to the last on the model.
      if indexPath.item == 0 || indexPath.item == component.model.items.count {
        currentIndexPath = IndexPath(item: component.model.items.count - 1, section: 0)
      /// Properly resolve padded items.
      /// Example with the last three items being padded.
      /// |19|20|0|1|2|
      } else if indexPath.item > component.model.items.count {
        currentIndexPath = IndexPath(item: indexPath.item - component.model.items.count - 1, section: 0)
      /// Resolve the regular items with an offset of -1 because the first item of the
      /// data source is equal to the last item.
      } else {
        currentIndexPath = IndexPath(item: indexPath.item - 1, section: 0)
      }
    } else {
      currentIndexPath = indexPath

      /// Safe guard to avoid crash when requesting an index path that is out of bounds.
      /// Discussion: This is legacy and I don't think this should be here, I'll leave
      /// it for now as we have tests for it.
      if indexPath.item >= component.model.items.count {
        return UICollectionViewCell()
      }
    }

    let reuseIdentifier = component.identifier(for: currentIndexPath)
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: currentIndexPath)
    viewPreparer.prepareView(cell, atIndex: currentIndexPath.item, in: component, parentFrame: cell.bounds)

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
    guard let component = component else {
      return 0
    }

    return component.model.items.count
  }

  /// Asks the data source for a cell to insert in a particular location of the table view. (required)
  ///
  /// - parameter tableView: A table-view object requesting the cell.
  /// - parameter indexPath: An index path locating a row in tableView.
  ///
  /// - returns: An object inheriting from UITableViewCell that the table view can use for the specified row. Will return the default table view cell for the current component based of kind.
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let component = component, indexPath.item < component.model.items.count else {
      return UITableViewCell()
    }

    if indexPath.item < component.model.items.count {
      component.model.items[indexPath.item].index = indexPath.row
    }

    let reuseIdentifier = component.identifier(for: indexPath)
    let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
    viewPreparer.prepareView(cell, atIndex: indexPath.row, in: component, parentFrame: cell.bounds)

    return cell
  }
}
