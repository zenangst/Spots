import UIKit
import GoldenRetriever
import Sugar

public class PageController: UIViewController, Itemble {

  var size = CGSize(width: 0, height: 320)

  lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .redColor()
    imageView.contentMode = .ScaleAspectFill
    imageView.autoresizingMask = [.FlexibleWidth]
    return imageView
    }()

  public init() {
    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func configure(inout item: ListItem) {
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
            self.imageView.image = image
          }
        }
      }
    }

    if imageView.superview == nil {
      view.addSubview(imageView)
    }
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    imageView.frame = view.bounds
  }
}
