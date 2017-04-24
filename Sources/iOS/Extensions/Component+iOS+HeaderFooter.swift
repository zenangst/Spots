import UIKit

extension Component {

  func setupHeader(with model: inout ComponentModel) {
    guard var header = model.header, headerView == nil else {
      return
    }

    if let (_, headerView) = Configuration.views.make(header.kind) {
      if let headerView = headerView,
        let componentable = headerView as? ItemConfigurable {
        let size = CGSize(width: view.frame.width,
                          height: componentable.preferredViewSize.height)
        componentable.configure(&header)
        model.header = header
        headerView.frame.size = size

        if let layout = model.layout {
          switch layout.headerMode {
            case .sticky:
            headerView.layer.zPosition = 100
            case .default:
            headerView.layer.zPosition = -1
          }
        }

        self.headerView = headerView
        backgroundView.addSubview(headerView)
      }
    }
  }

  func setupFooter(with model: inout ComponentModel) {
    guard var footer = model.footer, footerView == nil else {
      return
    }

    if let (_, footerView) = Configuration.views.make(footer.kind) {
      if let footerView = footerView,
        let componentable = footerView as? ItemConfigurable {
        let size = CGSize(width: view.frame.width,
                          height: componentable.preferredViewSize.height)
        componentable.configure(&footer)
        model.footer = footer
        footerView.frame.size = size
        footerView.layer.zPosition = -1
        self.footerView = footerView
        backgroundView.addSubview(footerView)
      }
    }
  }

  func layoutHeaderFooterViews(_ size: CGSize) {
    headerView?.frame.size.width = size.width
    footerView?.frame.size.width = size.width
    footerView?.frame.origin.y = view.frame.height - footerHeight

    if let layout = model.layout {
      headerView?.frame.origin.x = CGFloat(layout.inset.left)
      footerView?.frame.origin.x = CGFloat(layout.inset.left)
      headerView?.frame.size.width -= CGFloat(layout.inset.left + layout.inset.right)
      footerView?.frame.size.width -= CGFloat(layout.inset.left + layout.inset.right)
    }
  }

  func configureCollectionViewHeader(_ collectionView: CollectionView, with size: CGSize) {
    guard let collectionViewLayout = collectionView.collectionViewLayout as? GridableLayout else {
      return
    }

    guard let header = model.header else {
      return
    }

    guard let view = Configuration.views.make(header.kind)?.view else {
      return
    }

    collectionViewLayout.headerReferenceSize.width = collectionView.frame.size.width
    collectionViewLayout.headerReferenceSize.height = view.frame.size.height

    if collectionViewLayout.headerReferenceSize.width == 0.0 {
      collectionViewLayout.headerReferenceSize.width = size.width
    }

    guard let itemConfigurableView = view as? ItemConfigurable,
      collectionViewLayout.headerReferenceSize.height == 0.0 else {
        return
    }

    collectionViewLayout.headerReferenceSize.height = itemConfigurableView.preferredViewSize.height
  }
}
