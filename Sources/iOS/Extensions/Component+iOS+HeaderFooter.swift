import UIKit

extension Component {

  func setupHeader() {
    guard let header = model.header, headerView == nil else {
      reloadHeader()
      return
    }

    if let headerView = Configuration.views.make(header.kind)?.view {
      self.headerView = headerView
      reloadHeader()
      headerView.layer.zPosition = 100

      switch model.layout.headerMode {
      case .sticky:
        if model.kind != .list {
          view.addSubview(headerView)
        }
      case .default:
        if model.kind != .list {
          backgroundView.addSubview(headerView)
        }
      }
    }
  }

  func setupFooter() {
    guard let footer = model.footer, footerView == nil else {
      reloadFooter()
      return
    }

    if let footerView = Configuration.views.make(footer.kind)?.view {
      self.footerView = footerView
      reloadFooter()
      footerView.layer.zPosition = 99

      if model.kind != .list {
        view.addSubview(footerView)
      }
    }
  }

  func layoutHeaderFooterViews(_ size: CGSize) {
    headerView?.frame.size.width = size.width
    footerView?.frame.size.width = size.width

    if let collectionView = collectionView, model.kind == .carousel {
      footerView?.frame.origin.y = collectionView.collectionViewLayout.collectionViewContentSize.height - footerHeight
    } else {
      footerView?.frame.origin.y = view.frame.size.height - footerHeight
    }
  }
}
