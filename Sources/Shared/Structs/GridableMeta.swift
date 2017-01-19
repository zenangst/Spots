/// A meta struct used for scoping keys
public struct GridableMeta {
  /// A collection of static strings used for looking up meta properties on component
  public struct Key {
    /// A key used for looking up meta property section inset top
    public static let sectionInsetTop = "inset-top"
    /// A key used for looking up meta property section inset left
    public static let sectionInsetLeft = "inset-left"
    /// A key used for looking up meta property section inset right
    public static let sectionInsetRight = "inset-right"
    /// A key used for looking up meta property section inset bottom
    public static let sectionInsetBottom = "inset-bottom"
    /// A key used for looking up meta property item spacing
    public static let minimumInteritemSpacing = "item-spacing"
    /// A key used for looking up meta property line spacing
    public static let minimumLineSpacing = "line-spacing"
    /// A key used for looking up meta property left content inset
    public static let contentInsetTop = "content-inset-top"
    /// A key used for looking up meta property left content inset
    public static let contentInsetLeft = "content-inset-left"
    /// A key used for looking up meta property right content inset
    public static let contentInsetBottom = "content-inset-bottom"
    /// A key used for looking up meta property right content inset
    public static let contentInsetRight = "content-inset-right"
  }
}
