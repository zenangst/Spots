import CoreGraphics

extension Component {
  func reloadHeader() {
    guard let header = model.header, let headerView = headerView else {
      return
    }

    if let itemConfigurable = headerView as? ItemConfigurable {
      let size = CGSize(
        width: view.frame.width,
        height: itemConfigurable.computeSize(for: header, containerSize: view.frame.size).height
      )
      headerView.frame.size = size
      itemConfigurable.configure(with: header)
      model.header = header
    } else {
      if let model = header.model,
        let configurator = self.configuration.presenters[header.kind] {
        self.model.header?.size.height = configurator.configure(view: headerView, model: model, containerSize: view.frame.size).height
      }
    }
  }

  func reloadFooter() {
    guard let footer = model.footer, let footerView = footerView else {
      return
    }

    if let itemConfigurable = footerView as? ItemConfigurable {
      let size = CGSize(
        width: view.frame.width,
        height: itemConfigurable.computeSize(for: footer, containerSize: view.frame.size).height
      )
      footerView.frame.size = size
      itemConfigurable.configure(with: footer)
      model.footer = footer
    } else {
      if let model = footer.model,
        let configurator = self.configuration.presenters[footer.kind] {
        self.model.footer?.size.height = configurator.configure(view: footerView, model: model, containerSize: view.frame.size).height
      }
    }
  }
}
