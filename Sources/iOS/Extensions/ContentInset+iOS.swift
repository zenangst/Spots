import UIKit

extension ContentInset {

  func configure(scrollView: ScrollView) {
    scrollView.contentInset.top = CGFloat(self.top)
    scrollView.contentInset.left = CGFloat(self.left)
    scrollView.contentInset.bottom = CGFloat(self.bottom)
    scrollView.contentInset.right = CGFloat(self.right)
  }
}
