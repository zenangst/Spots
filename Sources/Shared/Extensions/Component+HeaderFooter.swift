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
    }
  }
}
