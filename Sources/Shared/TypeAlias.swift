#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif

/// A type alias for a anonymous completion
public typealias Completion = (() -> Void)?

#if os(OSX)
  public typealias View = NSView
  public typealias ScrollView = NoScrollView
  public typealias TableView = NSTableView
  public typealias CollectionView = NSCollectionView
  public typealias Nib = NSNib
  public typealias CollectionLayout = NSCollectionViewLayout
  public typealias EdgeInsets = NSEdgeInsets
#else
  public typealias View = UIView
  public typealias ScrollView = UIScrollView
  public typealias TableView = UITableView
  public typealias CollectionView = UICollectionView
  public typealias Nib = UINib
  public typealias CollectionLayout = GridableLayout
  public typealias EdgeInsets = UIEdgeInsets
#endif
