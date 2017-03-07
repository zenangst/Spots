import Cocoa

extension Spot {

  func setupHeader(kind: String) {
    guard !model.header.isEmpty, headerView == nil else {
      return
    }

    if let (_, headerView) = Configuration.views.make(model.header) {
      if let headerView = headerView,
        let componentable = headerView as? Componentable {
        let size = CGSize(width: view.frame.width,
                          height: componentable.preferredHeaderHeight)
        componentable.configure(model)
        headerView.frame.size = size
        self.headerView = headerView
        scrollView.addSubview(headerView)
      }
    }
  }

  func setupFooter(kind: String) {
    guard !model.footer.isEmpty, footerView == nil else {
      return
    }

    if let (_, footerView) = Configuration.views.make(model.footer) {
      if let footerView = footerView,
        let componentable = footerView as? Componentable {
        let size = CGSize(width: view.frame.width,
                          height: componentable.preferredHeaderHeight)
        componentable.configure(model)
        footerView.frame.size = size
        self.footerView = footerView
        scrollView.addSubview(footerView)
      }
    }
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
