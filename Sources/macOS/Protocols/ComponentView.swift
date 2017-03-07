import Cocoa

public protocol ComponentView {}
extension NSView : ComponentView {}
extension NSCollectionViewItem : ComponentView {}
