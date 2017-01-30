import Cocoa

extension Inset {

  /// Configure a scroll view with content insets.
  ///
  /// - Parameter scrollView: The scroll view that should be configured with content insets.
  func configure(scrollView: ScrollView) {
    scrollView.contentInsets.top = CGFloat(self.top)
    scrollView.contentInsets.left = CGFloat(self.left)
    scrollView.contentInsets.bottom = CGFloat(self.bottom)
    scrollView.contentInsets.right = CGFloat(self.right)
  }
}
