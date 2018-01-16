import CoreGraphics

extension Component {
  func reloadHeader() {
    guard let headerItem = model.header, let headerView = headerView else {
      return
    }

    if let itemConfigurable = headerView as? ItemConfigurable {
      let size = CGSize(
        width: view.frame.width,
        height: itemConfigurable.computeSize(for: headerItem, containerSize: view.frame.size).height
      )
      headerView.frame.size = size
      itemConfigurable.configure(with: headerItem)
      model.header = headerItem
    } else {
      if let model = headerItem.model,
        let configurator = self.configuration.presenters[headerItem.kind] {
        let size = configurator.configure(view: headerView, model: model, containerSize: view.frame.size)
        headerView.frame.size.height = size.height
        self.model.header?.size.height = size.height
      }
    }

    delegate?.component(self, didConfigureHeader: headerView, item: headerItem)
  }

  func reloadFooter() {
    guard let footerItem = model.footer, let footerView = footerView else {
      return
    }

    if let itemConfigurable = footerView as? ItemConfigurable {
      let size = CGSize(
        width: view.frame.width,
        height: itemConfigurable.computeSize(for: footerItem, containerSize: view.frame.size).height
      )
      footerView.frame.size = size
      itemConfigurable.configure(with: footerItem)
      model.footer = footerItem
    } else {
      if let model = footerItem.model,
        let configurator = self.configuration.presenters[footerItem.kind] {
        let size = configurator.configure(view: footerView, model: model, containerSize: view.frame.size)
        footerView.frame.size.height = size.height
        self.model.footer?.size.height = size.height
      }
    }

    delegate?.component(self, didConfigureFooter: footerView, item: footerItem)
  }
}
