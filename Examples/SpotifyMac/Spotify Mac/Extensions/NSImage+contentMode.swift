import Cocoa

enum ContentMode: Int {

  case ScaleToAspectFill
  case ScaleToAspectFit
}

extension NSImageView {

  var contentMode: ContentMode {
    set {
      guard let image = image else { return }
      let rect = self.convertRect(self.bounds, toView: nil)
      guard var _ = superview?.frame else { return }

      var imageSize = CGSize(width: image.size.width, height: image.size.height)

      switch newValue {
      case .ScaleToAspectFill:
        if imageSize.height < imageSize.width {
          imageSize.width = floor((imageSize.width/imageSize.height) * rect.size.height)
          imageSize.height = rect.size.height
        } else {
          imageSize.height = floor((imageSize.height/imageSize.width) * rect.size.width)
          imageSize.width = rect.size.width
        }

        image.size = CGSize(width: imageSize.width, height: imageSize.height)
      case .ScaleToAspectFit:
        if imageSize.height < imageSize.width {
          imageSize.height = frame.size.height
          imageSize.width = frame.size.width
        } else {
          imageSize.width = frame.size.width
          imageSize.height = frame.size.height
        }

        image.size = CGSize(width: imageSize.width, height: imageSize.height)
      }
    }
    get {
      return .ScaleToAspectFill
    }
  }

}
