import Spots
import Brick

public class FeaturedGridItem: GridSpotItem {

  public override func configure(inout item: ViewModel) {
    super.configure(&item)

    if let imageView = imageView where
      item.image.isPresent && item.image.hasPrefix("http") {
      imageView.frame.size.width = item.size.width - 50
      imageView.frame.size.height = item.size.height - 50
      imageView.frame.origin.y = 50
      imageView.frame.origin.x = 50
      imageView.imageAlignment = .AlignCenter
      imageView.setImage(NSURL(string: item.image))

      titleLabel.frame.origin.x = 50
      subtitleLabel.frame.origin.x = 50
    }
  }

}
