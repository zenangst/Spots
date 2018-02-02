import UIKit

extension Component {
  func setupInfiniteScrolling() {
    guard let componentDataSource = componentDataSource,
      model.items.count >= componentDataSource.buffer else {
        return
    }

    let item = componentDataSource.buffer
    view.layoutIfNeeded()
    handleInfiniteScrolling()

    guard let componentFlowLayout = collectionView?.flowLayout as? ComponentFlowLayout,
      (item > 0 && item < componentFlowLayout.cachedFrames.count)
      else {
        return
    }

    let frame = componentFlowLayout.cachedFrames[item]
    let x: CGFloat

    switch model.interaction.paginate {
    case .page, .item:
      x = round(frame.origin.x - CGFloat(model.layout.inset.left))
    case .disabled:
      x = round(frame.origin.x - CGFloat(model.layout.itemSpacing * 1.5))
    }

    collectionView?.setContentOffset(.init(x: x, y: 0), animated: false)
  }
}
