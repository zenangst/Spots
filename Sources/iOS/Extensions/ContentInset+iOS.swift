import UIKit

extension ContentInset {

  /// Configure a scroll view with content insets.
  ///
  /// - Parameter scrollView: The scroll view that should be configured with content insets.
  func configure(scrollView: ScrollView) {
    scrollView.contentInset.top = CGFloat(self.top)
    scrollView.contentInset.left = CGFloat(self.left)
    scrollView.contentInset.bottom = CGFloat(self.bottom)
    scrollView.contentInset.right = CGFloat(self.right)
  }
}
