import UIKit

extension Component {

  func setupHeader(with model: inout ComponentModel) {
    guard var header = model.header, headerView == nil else {
      return
    }

    if let (_, headerView) = Configuration.views.make(header.kind) {
      if let headerView = headerView,
        let itemConfigurable = headerView as? ItemConfigurable {
        let size = CGSize(width: view.frame.width,
                          height: itemConfigurable.preferredViewSize.height)
        itemConfigurable.configure(&header)
        model.header = header
        headerView.frame.size = size
        headerView.layer.zPosition = 100

        if let layout = model.layout {
          switch layout.headerMode {
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

        self.headerView = headerView
      }
    }
  }

  func setupFooter(with model: inout ComponentModel) {
    guard var footer = model.footer, footerView == nil else {
      return
    }

    if let (_, footerView) = Configuration.views.make(footer.kind) {
      if let footerView = footerView,
        let itemConfigurable = footerView as? ItemConfigurable {
        let size = CGSize(width: view.frame.width,
                          height: itemConfigurable.preferredViewSize.height)
        itemConfigurable.configure(&footer)
        model.footer = footer
        footerView.frame.size = size
        footerView.layer.zPosition = 99
        self.footerView = footerView

        if model.kind != .list {
          view.addSubview(footerView)
        }
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

    if let layout = model.layout {
      headerView?.frame.origin.x = CGFloat(layout.inset.left)
      footerView?.frame.origin.x = CGFloat(layout.inset.left)
      headerView?.frame.size.width -= CGFloat(layout.inset.left + layout.inset.right)
      footerView?.frame.size.width -= CGFloat(layout.inset.left + layout.inset.right)
    }
  }
}
