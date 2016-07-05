import Cocoa

enum ContentMode: Int {

  case ScaleToAspectFill

}

extension NSImageView {

  var contentMode: ContentMode {
    set {
      guard let image = image else { return }
      let rect = self.convertRect(self.bounds, toView: nil)

      var imageSize = CGSize(width: image.size.width, height: image.size.height)
      if imageSize.height < imageSize.width {
        imageSize.width = floor((imageSize.width/imageSize.height) * rect.size.height)
        imageSize.height = rect.size.height
      } else {
        imageSize.height = floor((imageSize.height/imageSize.width) * rect.size.width)
        imageSize.width = rect.size.width
      }

      image.size = CGSize(width: imageSize.width, height: imageSize.height)
    }
    get {
      return .ScaleToAspectFill
    }
  }

}
