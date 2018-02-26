import UIKit

extension Component {
  func setupInfiniteScrolling() {
    collectionView?.collectionViewLayout.prepare()

    guard let collectionView = collectionView,
      let componentDataSource = componentDataSource,
      model.items.count >= componentDataSource.buffer,
      let frame = collectionView.flowLayout?.layoutAttributesForItem(at: IndexPath(item: componentDataSource.buffer, section: 0))?.frame else {
        return
    }

    view.layoutIfNeeded()
    handleInfiniteScrolling()
    let x: CGFloat
    switch model.interaction.paginate {
    case .page, .item:
      x = round(frame.origin.x - CGFloat(model.layout.inset.left))
    case .disabled:
      x = round(frame.origin.x - CGFloat(model.layout.itemSpacing * 1.5))
    }
    collectionView.setContentOffset(.init(x: x, y: 0), animated: false)
  }
}
