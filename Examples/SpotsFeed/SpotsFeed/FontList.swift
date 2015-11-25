import UIKit

public struct FontList {

  public struct Post {
    public static var author = UIFont.boldSystemFontOfSize(14)
    public static var date = UIFont.systemFontOfSize(12)
    public static var text = UIFont.systemFontOfSize(14)
    public static var media = UIFont.boldSystemFontOfSize(36)
  }

  public struct Comment {
    public static var author = UIFont.boldSystemFontOfSize(14)
    public static var text = UIFont.systemFontOfSize(14)
    public static var date = UIFont.systemFontOfSize(12)
  }

  public struct Information {
    public static var like = UIFont.systemFontOfSize(12)
    public static var comment = UIFont.systemFontOfSize(12)
    public static var seen = UIFont.italicSystemFontOfSize(12)
  }

  public struct Action {
    public static var like = UIFont.boldSystemFontOfSize(14)
    public static var comment = UIFont.boldSystemFontOfSize(14)
  }
}
