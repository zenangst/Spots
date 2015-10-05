import UIKit
import Tailor
import Sugar
import GoldenRetriever

protocol ComponentSizeDelegate: class {
  func sizeDidUpdate()
}

protocol Listable { }

protocol ComponentContainer: class {
  weak var sizeDelegate: ComponentSizeDelegate? { get set }
  var component: Component { get set }

  func render() -> UIView
}

class ListComponentCell: UITableViewCell {

  override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
    super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

}

class ListComponent: NSObject, ComponentContainer {

  let itemHeight: CGFloat = 44

  var component: Component
  weak var sizeDelegate: ComponentSizeDelegate?

  lazy var tableView: UITableView = { [unowned self] in
    let tableView = UITableView()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.scrollEnabled = false
    tableView.frame.size.width = UIScreen.mainScreen().bounds.width

    return tableView
  }()

  init(component: Component) {
    self.component = component
    super.init()
    for item in component.items {
      self.tableView.registerClass(ListComponentCell.self, forCellReuseIdentifier: "ListCell\(item.type)")
    }
  }

  func render() -> UIView
  {
    return tableView
  }
}

extension ListComponent: UITableViewDelegate {

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let item = component.items[indexPath.row]
    guard let uri = item.uri, url = NSURL(string: uri) else { return }
    UIApplication.sharedApplication().openURL(url)
  }

  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return itemHeight
  }
}

extension ListComponent: UITableViewDataSource {

  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return component.title
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if tableView.frame.size.height != tableView.contentSize.height {
      tableView.frame.size.height = tableView.contentSize.height
      sizeDelegate?.sizeDidUpdate()
    }

    return component.items.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let item = component.items[indexPath.row]
    let cell = tableView.dequeueReusableCellWithIdentifier("ListCell\(item.type)")

    cell!.textLabel!.text = item.title
    cell!.textLabel!.textColor = .blackColor()
    
    if !item.subtitle.isEmpty {
      cell!.detailTextLabel?.text = item.subtitle
      cell!.detailTextLabel?.textColor = .blackColor()
    }


    if item.image != "" {
      let resource = item.image
      let fido = GoldenRetriever()
      fido.fetch(resource) { data, error in
        guard let data = data else { return }
        let image = UIImage(data: data)
        cell!.imageView!.contentMode = .ScaleAspectFill
        cell!.imageView!.image = image
      }
    } else {
      cell!.imageView!.image = nil
    }

    return cell!
  }
}
