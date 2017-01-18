import Cocoa

extension ContentInset {

  func configure(scrollView: ScrollView) {
    scrollView.contentInsets.top = CGFloat(self.top)
    scrollView.contentInsets.left = CGFloat(self.left)
    scrollView.contentInsets.bottom = CGFloat(self.bottom)
    scrollView.contentInsets.right = CGFloat(self.right)
  }
}
