import UIKit

extension SectionInset {

  public func configure(layout: CollectionLayout) {
    layout.sectionInset.top = CGFloat(self.top)
    layout.sectionInset.left = CGFloat(self.left)
    layout.sectionInset.bottom = CGFloat(self.bottom)
    layout.sectionInset.right = CGFloat(self.right)
  }
}
