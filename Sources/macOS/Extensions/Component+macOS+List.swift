import Cocoa

extension Component {

  func setupTableView(_ tableView: TableView, with size: CGSize) {
    scrollView.addSubview(tableView)

    model.items.enumerated().forEach {
      model.items[$0.offset].size.width = size.width
    }

    tableView.frame.size = size

    prepareItems()

    tableView.dataSource = componentDataSource
    tableView.delegate = componentDelegate
    tableView.backgroundColor = NSColor.clear
    tableView.allowsColumnReordering = false
    tableView.allowsColumnResizing = false
    tableView.allowsColumnSelection = false
    tableView.allowsEmptySelection = true
    tableView.allowsMultipleSelection = false
    tableView.headerView = nil
    tableView.selectionHighlightStyle = .none
    tableView.allowsTypeSelect = true
    tableView.focusRingType = .none
    tableView.target = self
    tableView.action = #selector(self.action(_:))
    tableView.doubleAction = #selector(self.doubleAction(_:))
    tableView.sizeToFit()

    guard tableView.tableColumns.isEmpty else {
      return
    }

    let column = NSTableColumn(identifier: "tableview-column")
    column.maxWidth = 250
    column.width = 250
    column.minWidth = 150

    tableView.addTableColumn(column)
  }

  func layoutTableView(_ tableView: TableView, with size: CGSize) {
    tableView.frame.origin.y = headerView?.frame.size.height ?? 0.0
    tableView.sizeToFit()
    tableView.frame.size.width = size.width

    if let layout = model.layout {
      tableView.frame.origin.x = CGFloat(layout.inset.left)
      tableView.frame.size.width -= CGFloat(layout.inset.left + layout.inset.right)
    }

    scrollView.frame.size.height = tableView.frame.height + headerHeight + footerHeight
  }
}
