import UIKit

extension Inset {

  /// Configure a scroll view with content insets.
  ///
  /// - Parameter scrollView: The scroll view that should be configured with content insets.
  func configure(scrollView: ScrollView) {
    scrollView.contentInset.top = CGFloat(self.top)
    scrollView.contentInset.left = CGFloat(self.left)
    scrollView.contentInset.bottom = CGFloat(self.bottom)
    scrollView.contentInset.right = CGFloat(self.right)
  }

  /// Configure section insets on flow layouts
  ///
  /// - Parameter layout: The flow layout that should be configured.
  public func configure(layout: FlowLayout) {
    layout.sectionInset.top = CGFloat(self.top)
    layout.sectionInset.left = CGFloat(self.left)
    layout.sectionInset.bottom = CGFloat(self.bottom)
    layout.sectionInset.right = CGFloat(self.right)
  }
}
