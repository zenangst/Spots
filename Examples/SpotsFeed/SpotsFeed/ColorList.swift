import UIKit

public struct ColorList {

  public struct Basis {
    public static var tableViewBackground = UIColor(red:0.91, green:0.92, blue:0.95, alpha:1)
    public static var highlightedColor = UIColor.redColor()
  }

  public struct Post {
    public static var author = UIColor.blackColor()
    public static var date = UIColor.lightGrayColor()
    public static var text = UIColor.blackColor()
    public static var media = UIColor.blackColor().colorWithAlphaComponent(0.35)
  }

  public struct Comment {
    public static var background = UIColor(red:0.97, green:0.98, blue:0.98, alpha:1)
    public static var author = UIColor.blackColor()
    public static var text = UIColor.blackColor()
    public static var date = UIColor.lightGrayColor()
  }

  public struct Information {
    public static var like = UIColor.lightGrayColor()
    public static var comment = UIColor.lightGrayColor()
    public static var seen = UIColor.lightGrayColor()
  }

  public struct Action {
    public static var like = UIColor.grayColor()
    public static var comment = UIColor.grayColor()
    public static var liked = UIColor.redColor()
  }
}
