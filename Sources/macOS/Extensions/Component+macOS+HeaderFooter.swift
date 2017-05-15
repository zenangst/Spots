import Cocoa

extension Component {

  func setupHeader(with model: inout ComponentModel) {
    guard let header = model.header, headerView == nil else {
      return
    }

    if let (_, headerView) = Configuration.views.make(header.kind) {
      if let headerView = headerView,
        let componentable = headerView as? ItemConfigurable {
        let size = CGSize(width: view.frame.width,
                          height: componentable.preferredViewSize.height)
        componentable.configure(with: header)
        model.header = header
        headerView.frame.size = size
        self.headerView = headerView
        scrollView.addSubview(headerView)
      }
    }
  }

  func setupFooter(with model: inout ComponentModel) {
    guard let footer = model.footer, footerView == nil else {
      return
    }

    if let (_, footerView) = Configuration.views.make(footer.kind) {
      if let footerView = footerView,
        let componentable = footerView as? ItemConfigurable {
        let size = CGSize(width: view.frame.width,
                          height: componentable.preferredViewSize.height)
        componentable.configure(with: footer)
        model.footer = footer
        footerView.frame.size = size
        self.footerView = footerView
        scrollView.addSubview(footerView)
      }
    }
  }

  func layoutHeaderFooterViews(_ size: CGSize) {
    headerView?.frame.size.width = size.width

    if let layout = model.layout {
      headerView?.frame.origin.y = CGFloat(layout.inset.top)
    }

    footerView?.frame.size.width = size.width
    footerView?.frame.origin.y = scrollView.frame.height - footerHeight
  }
}
