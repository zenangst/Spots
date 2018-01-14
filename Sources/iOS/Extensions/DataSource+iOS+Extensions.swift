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
    guard let component = component else {
      return 0
    }

    let numberOfItemsInSection = component.model.items.count

    guard component.model.layout.infiniteScrolling else {
      return numberOfItemsInSection
    }

    return numberOfItemsInSection + 2 * buffer
  }

  /// Asks the data source for the number of items in the specified section. (required)
  ///
  /// - parameter collectionView: An object representing the collection view requesting this information.
  /// - parameter section:        An index number identifying a section in collectionView. This index value is 0-based.
  ///
  /// - returns: The number of rows in section.
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let component = component else {
      return UICollectionViewCell()
    }

    let currentIndexPath: IndexPath = indexPathManager.computeIndexPath(indexPath)
    let reuseIdentifier = component.identifier(for: currentIndexPath)
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: currentIndexPath)
    viewPreparer.prepareView(cell, atIndex: currentIndexPath.item, in: component, parentFrame: cell.bounds)

    return cell
  }

  #if os(tvOS)
  public func indexTitles(for collectionView: UICollectionView) -> [String]? {
    guard let component = component else {
      return nil
    }
    return component.delegate?.componentIndexTitles(component)
  }

  public func collectionView(_ collectionView: UICollectionView, indexPathForIndexTitle title: String, at index: Int) -> IndexPath {
    guard let component = component,
      let item = component.item(at: index),
      let indexPath = component.delegate?.componentIndexPath(component, item: item, at: index, for: title) else {
        return IndexPath(item: index, section: 0)
    }

    return indexPath
  }
  #endif
}

extension DataSource: UITableViewDataSource {

  /// Tells the data source to return the number of rows in a given section of a table view. (required)
  ///
  /// - parameter tableView: The table-view object requesting this information.
  /// - parameter section: An index number identifying a section in tableView.
  ///
  /// - returns: The number of rows in section.
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let numberOfRowsInSection = resolveComponent({ $0.model.items.count }, fallback: 0)
    return numberOfRowsInSection
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
