import Spots
import Brick

public class HeroGridItem: GridSpotItem {

  public override func configure(inout item: ViewModel) {

    super.configure(&item)
    if let imageView = imageView where
      item.image.isPresent && item.image.hasPrefix("http") {
      imageView.autoresizingMask = .ViewWidthSizable
      imageView.frame.size.width = item.size.width
      imageView.frame.size.height = item.size.height
      imageView.imageScaling = .ScaleProportionallyUpOrDown
      imageView.setImage(NSURL(string: item.image))
    }
  }
}
