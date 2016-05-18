#if os(iOS)
  import UIKit
#else
  import Cocoa
#endif

/// A type alias for a anonymous completion
public typealias Completion = (() -> Void)?

#if os(iOS)
public typealias RegularView = UIView
public typealias ScrollView = UIScrollView
public typealias TableView = UITableView
public typealias CollectionView = UICollectionView
#else
public typealias RegularView = NSView
public typealias ScrollView = NoScrollView
public typealias TableView = NSTableView
public typealias CollectionView = NSCollectionView
#endif
