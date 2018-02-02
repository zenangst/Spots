import UIKit

extension Component {
  /// Asks the delegate if the specified item should be selected.
  ///
  /// - parameter collectionView: The collection view object that is asking whether the selection should change.
  /// - parameter indexPath: The index path of the cell to be selected.
  ///
  /// - returns: true if the item should be selected or false if it should not.
  @objc(collectionView:shouldSelectItemAtIndexPath:) public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    if let indexPath = collectionView.indexPathsForSelectedItems?.first {
      collectionView.deselectItem(at: indexPath, animated: true)
      return false
    }
    return true
  }

  func setupInfiniteScrolling() {
    guard let componentDataSource = componentDataSource,
      model.items.count >= componentDataSource.buffer else {
        return
    }

    let indexPath = IndexPath(item: componentDataSource.buffer, section: 0)

    if var x = initialXCoordinateItemAtIndexPath(indexPath) {
      x += CGFloat(model.layout.inset.left)
      collectionView?.contentOffset.x = x
      collectionView?.setContentOffset(.init(x: x, y: 0), animated: false)
      view.setNeedsLayout()
      view.layoutIfNeeded()
    }

    componentDelegate?.manualFocusedIndexPath = indexPath
    if #available(tvOS 9.0, *) {
      view.setNeedsFocusUpdate()
    }
  }

  private func initialXCoordinateItemAtIndexPath(_ indexPath: IndexPath) -> CGFloat? {
    guard let attributes = collectionView?.layoutAttributesForItem(at: indexPath) else {
      return nil
    }

    let span: Double = model.layout.span > 1 ? model.layout.span : 1
    var centerAlignment = CGFloat(model.layout.itemSpacing * span)
    var remainingWidth = attributes.size.width + centerAlignment * 2
    while remainingWidth < view.frame.size.width {
      remainingWidth *= 2
      centerAlignment -= CGFloat(model.layout.itemSpacing)
    }

    return attributes.frame.minX - centerAlignment
  }
}
