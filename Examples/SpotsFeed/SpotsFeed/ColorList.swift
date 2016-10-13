import UIKit

public struct ColorList {

  public struct Basis {
    public static var tableViewBackground = UIColor(red:0.91, green:0.92, blue:0.95, alpha:1)
    public static var highlightedColor = UIColor.red
  }

  public struct Post {
    public static var author = UIColor.black
    public static var date = UIColor.lightGray
    public static var text = UIColor.black
    public static var media = UIColor.black.withAlphaComponent(0.35)
  }

  public struct Comment {
    public static var background = UIColor(red:0.97, green:0.98, blue:0.98, alpha:1)
    public static var author = UIColor.black
    public static var text = UIColor.black
    public static var date = UIColor.lightGray
  }

  public struct Information {
    public static var like = UIColor.lightGray
    public static var comment = UIColor.lightGray
    public static var seen = UIColor.lightGray
  }

  public struct Action {
    public static var like = UIColor.gray
    public static var comment = UIColor.gray
    public static var liked = UIColor.red
  }
}
