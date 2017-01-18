import Cocoa

extension SectionInset {

  func configure(layout: FlowLayout) {
    layout.sectionInset.top = CGFloat(self.top)
    layout.sectionInset.left = CGFloat(self.left)
    layout.sectionInset.bottom = CGFloat(self.bottom)
    layout.sectionInset.right = CGFloat(self.right)
  }
}
