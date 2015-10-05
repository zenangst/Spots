import UIKit
import Tailor
import Sugar

protocol ComponentSizeDelegate: class {
  func sizeDidUpdate()
}

protocol Component: class {
  weak var sizeDelegate: ComponentSizeDelegate? { get set }

  func render() -> UIView
}

class ListComponent: NSObject, Component {

  let itemHeight: CGFloat = 44
  let title: String

  var items = [ListItem]()
  weak var sizeDelegate: ComponentSizeDelegate?

  lazy var tableView: UITableView = { [unowned self] in
    let tableView = UITableView()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.scrollEnabled = false
    tableView.frame.size.width = UIScreen.mainScreen().bounds.width

    return tableView
  }()

  init(title: String, items: [ListItem]) {
    self.title = title
    self.items = items
    super.init()
    for item in items {
      self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: item.type)
    }
  }

  func render() -> UIView
  {
    return tableView
  }
}

extension ListComponent: UITableViewDelegate {

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let item = items[indexPath.row]
    guard let uri = item.uri, url = NSURL(string: uri) else { return }
    UIApplication.sharedApplication().openURL(url)
  }

  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return itemHeight
  }
}

extension ListComponent: UITableViewDataSource {

  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return title
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if tableView.frame.size.height != tableView.contentSize.height {
      tableView.frame.size.height = tableView.contentSize.height
      sizeDelegate?.sizeDidUpdate()
    }

    return items.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let item = items[indexPath.row]
    let cell = tableView.dequeueReusableCellWithIdentifier(item.type)

    cell!.textLabel!.text = item.title
    cell!.textLabel!.textColor = .blackColor()
    cell!.detailTextLabel?.text = item.subtitle
    cell!.detailTextLabel?.textColor = .blackColor()

    return cell!
  }
}
