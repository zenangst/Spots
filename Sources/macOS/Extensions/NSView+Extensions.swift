import Cocoa

/// Extension for macOS to gain layoutSubviews
public extension NSView {
  func setNeedsLayout() {
    needsLayout = true
  }

  @objc func layoutSubviews() {
    layout()
  }

  func layoutIfNeeded() {
    layoutSubtreeIfNeeded()
  }
}
