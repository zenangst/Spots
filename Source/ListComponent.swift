import UIKit
import Tailor
import Sugar

protocol Component {
  func render() -> UIView
}

struct ListItem {
  var title = ""
  var subtitle = ""
  var image = ""
  var type = ""
  var uri: String?
  
  init(json: JSONDictionary) {
    self.title <- json.property("title")
    self.subtitle <- json.property("subtitle")
    self.image <- json.property("image")
    self.type <- json.property("type")
    self.uri <- json.property("uri")
  }
}

class ListComponent: NSObject, Component {

  lazy var tableView: UITableView = { [unowned self] in
    let tableView = UITableView()
    tableView.delegate = self
    tableView.dataSource = self

    return tableView
  }()

  var items = [ListItem]()
  let itemHeight: CGFloat = 44

  init(items: [ListItem]) {
    self.items = items
    super.init()
    for item in items {
      self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: item.type)
    }

    tableView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, itemHeight * CGFloat(items.count))
  }

  func render() -> UIView
  {
    tableView.backgroundColor = .yellowColor()
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

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
