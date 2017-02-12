import UIKit

// MARK: - Extensions for Spotable objects that also confirm to Listable
public extension Listable {

  /// Return table view as a scroll view
  ///
  /// - returns: UIScrollView: Returns a UITableView as a UIScrollView
  ///
  var view: UIScrollView {
    return tableView
  }

  /// Layout using size
  /// - parameter size: A CGSize to set the width of the table view
  ///
  public func layout(_ size: CGSize) {
    tableView.frame.size.width = size.width - (tableView.contentInset.left)
    tableView.frame.origin.x = size.width / 2 - tableView.frame.width / 2

    guard let componentSize = component.size else {
      return
    }
    tableView.frame.size.height = componentSize.height
  }

  public func sizeForItem(at indexPath: IndexPath) -> CGSize {
    return CGSize(
      width:  item(at: indexPath)?.size.width  ?? 0.0,
      height: item(at: indexPath)?.size.height ?? 0.0
    )
  }

  /// Scroll to Item matching predicate
  ///
  /// - parameter includeElement: A filter predicate to find a view model
  ///
  /// - returns: A calculate CGFloat based on what the includeElement matches
  public func scrollTo(_ includeElement: (Item) -> Bool) -> CGFloat {
    guard let item = items.filter(includeElement).first else { return 0.0 }

    return component.items[0...item.index]
      .reduce(0, { $0 + $1.size.height })
  }

  /// Register all identifier to UITableView.
  public func register() {
    for (identifier, item) in Configuration.views.storage {
      switch item {
      case .classType(_):
        self.tableView.register(ListHeaderFooterWrapper.self, forHeaderFooterViewReuseIdentifier: identifier)
        self.tableView.register(ListWrapper.self, forCellReuseIdentifier: identifier)
      case .nib(let nib):
        self.tableView.register(nib, forCellReuseIdentifier: identifier)
      }
    }

    for (identifier, item) in type(of: self).views.storage {
      switch item {
      case .classType(let classType):
        guard classType.init() is UITableViewCell else {
          self.tableView.register(ListWrapper.self, forCellReuseIdentifier: identifier)
          return
        }
        self.tableView.register(classType, forCellReuseIdentifier: identifier)
      case .nib(let nib):
        self.tableView.register(nib, forCellReuseIdentifier: identifier)
      }
    }

    for (identifier, item) in type(of: self).headers.storage {
      switch item {
      case .classType(let classType):
        self.tableView.register(classType, forHeaderFooterViewReuseIdentifier: identifier)
      case .nib(let nib):
        self.tableView.register(nib, forHeaderFooterViewReuseIdentifier: identifier)
      }
    }
  }
}
