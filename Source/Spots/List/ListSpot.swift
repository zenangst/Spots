import UIKit
import Tailor
import Sugar
import GoldenRetriever

class ListSpot: NSObject, Spotable {

  static var cells = [String: UITableViewCell.Type]()

  let itemHeight: CGFloat = 44

  var component: Component
  weak var sizeDelegate: SpotSizeDelegate?

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
      let componentCellClass = ListSpot.cells[item.type] ?? ListSpotCell.self
      self.tableView.registerClass(componentCellClass,
        forCellReuseIdentifier: "ListCell\(item.type)")
    }
  }

  func render() -> UIView {
    return tableView
  }
}

extension ListSpot: UITableViewDelegate {

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let item = component.items[indexPath.row]
    guard let uri = item.uri, url = NSURL(string: uri) else { return }
    UIApplication.sharedApplication().openURL(url)
  }

  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return itemHeight
  }
}

extension ListSpot: UITableViewDataSource {

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
      let qualityOfServiceClass = QOS_CLASS_BACKGROUND
      let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)

      dispatch(backgroundQueue) {
        fido.fetch(resource) { data, error in
          guard let data = data else { return }
          let image = UIImage(data: data)
          dispatch {
            cell!.imageView!.contentMode = .ScaleAspectFill
            cell!.imageView!.image = image
            cell?.layoutSubviews()
          }
        }
      }
    } else {
      cell!.imageView!.image = nil
    }

    return cell!
  }
}
