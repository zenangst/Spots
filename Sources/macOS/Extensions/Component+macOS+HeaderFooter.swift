import Cocoa

extension Component {

  func setupHeader(with model: inout ComponentModel) {
    guard var header = model.header, headerView == nil else {
      return
    }

    guard let headerView = Configuration.views.make(header.kind)?.view else {
      return
    }

    guard let itemConfigurable = headerView as? ItemConfigurable else {
      return
    }

    let size = CGSize(width: view.frame.width,
                      height: itemConfigurable.preferredViewSize.height)
    itemConfigurable.configure(&header)
    model.header = header
    headerView.frame.size = size
    self.headerView = headerView
    scrollView.addSubview(headerView)
  }

  func setupFooter(with model: inout ComponentModel) {
    guard var footer = model.footer, footerView == nil else {
      return
    }

    guard let footerView = Configuration.views.make(footer.kind)?.view else {
      return
    }

    guard let itemConfigurable = footerView as? ItemConfigurable else {
      return
    }

    let size = CGSize(width: view.frame.width,
                      height: itemConfigurable.preferredViewSize.height)
    itemConfigurable.configure(&footer)
    model.footer = footer
    footerView.frame.size = size
    self.footerView = footerView
    scrollView.addSubview(footerView)
  }

  func layoutHeaderFooterViews(_ size: CGSize) {
    headerView?.frame.size.width = size.width
    footerView?.frame.size.width = size.width
    footerView?.frame.origin.y = scrollView.frame.height - footerHeight

    if let layout = model.layout {
      headerView?.frame.origin.x = CGFloat(layout.inset.left)
      footerView?.frame.origin.x = CGFloat(layout.inset.left)
      headerView?.frame.size.width -= CGFloat(layout.inset.left + layout.inset.right)
      footerView?.frame.size.width -= CGFloat(layout.inset.left + layout.inset.right)
    }
  }
}
