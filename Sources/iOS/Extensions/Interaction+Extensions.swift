import UIKit

extension Interaction {

  public func configure(spot: Gridable) {
    #if os(iOS)
      spot.collectionView.isPagingEnabled = paginate == .byPage
    #endif
  }
}
