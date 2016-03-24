import UIKit
import Spots

class JSONController: UIViewController {

  lazy var scrollView: UIScrollView = UIScrollView()

  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.text = "JSON"
    label.font = UIFont(name: "HelveticaNeue-Medium", size: 20)!
    label.textColor = UIColor(red:0.86, green:0.86, blue:0.86, alpha:1)
    label.textAlignment = .Center
    label.numberOfLines = 0
    label.sizeToFit()

    return label
    }()

  lazy var textView: UITextView = {
    let textView = UITextView()
    textView.font = UIFont(name: "Menlo", size: 13)

    return textView
    }()

  lazy var submitButton: UIButton = { [unowned self] in
    let button = UIButton()
    button.addTarget(self, action: #selector(submitButtonDidPress(_:)), forControlEvents: .TouchUpInside)
    button.setTitle("Build", forState: .Normal)

    return button
    }()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.whiteColor()

    navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .Plain, target: nil, action: nil)

    [titleLabel, textView, submitButton].forEach {
      view.addSubview($0)
    }

    submitButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
    submitButton.layer.borderColor = UIColor.grayColor().CGColor
    submitButton.layer.borderWidth = 1.5
    submitButton.layer.cornerRadius = 7.5

    textView.layer.borderColor = UIColor.lightGrayColor().CGColor
    textView.layer.borderWidth = 1.0
    textView.layer.cornerRadius = 7.5

    let bundlePath = NSBundle.mainBundle().pathForResource("components", ofType: "json")
    let data = NSFileManager.defaultManager().contentsAtPath(bundlePath!)
    let json = NSString(data: data!, encoding:NSUTF8StringEncoding) as! String

    textView.text = json

    setupFrames()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    setupFrames()
  }

  // MARK: Action methods

  func submitButtonDidPress(button: UIButton? = nil) {
    if let data = textView.text.dataUsingEncoding(NSUTF8StringEncoding) {

      do {
        let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String : AnyObject]
        if let json = json {
          SpotFactory.DefaultSpot = ListSpot.self

          let components = Parser.parse(json)
          let controller = SpotsController(spots: components)
          navigationController?.pushViewController(controller, animated: true)
        }
      } catch {
        let alertController = UIAlertController(title: "Error", message: "Unable to resolve JSON", preferredStyle: .Alert)
        let doneAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
        alertController.addAction(doneAction)
        presentViewController(alertController, animated: true, completion: nil)
      }
    }
  }

  // MARK - Configuration

  func setupFrames() {
    let totalSize = UIScreen.mainScreen().bounds

    if [.Portrait, .PortraitUpsideDown].contains(UIApplication.sharedApplication().statusBarOrientation) {
      titleLabel.frame.origin = CGPoint(x: (totalSize.width - titleLabel.frame.width) / 2, y: 90)
      textView.frame = CGRect(x: 25, y: titleLabel.frame.maxY + 25, width: totalSize.width - 25 * 2, height: 350)
      submitButton.frame = CGRect(x: 50, y: textView.frame.maxY + 50, width: totalSize.width - 100, height: 50)
    } else {
      titleLabel.frame.origin = CGPoint(x: (totalSize.width - titleLabel.frame.width) / 2, y: 50)
      textView.frame = CGRect(x: 25, y: titleLabel.frame.maxY + 25, width: totalSize.width - 25 * 2, height: 150)
      submitButton.frame = CGRect(x: 50, y: textView.frame.maxY + 50, width: totalSize.width - 100, height: 50)
    }
  }

}
