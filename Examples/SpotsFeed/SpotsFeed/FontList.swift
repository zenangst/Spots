import UIKit

public struct FontList {

  public struct Post {
    public static var author = UIFont.boldSystemFont(ofSize: 14)
    public static var date = UIFont.systemFont(ofSize: 12)
    public static var text = UIFont.systemFont(ofSize: 14)
    public static var media = UIFont.boldSystemFont(ofSize: 36)
  }

  public struct Comment {
    public static var author = UIFont.boldSystemFont(ofSize: 14)
    public static var text = UIFont.systemFont(ofSize: 14)
    public static var date = UIFont.systemFont(ofSize: 12)
  }

  public struct Information {
    public static var like = UIFont.systemFont(ofSize: 12)
    public static var comment = UIFont.systemFont(ofSize: 12)
    public static var seen = UIFont.italicSystemFont(ofSize: 12)
  }

  public struct Action {
    public static var like = UIFont.boldSystemFont(ofSize: 14)
    public static var comment = UIFont.boldSystemFont(ofSize: 14)
  }
}
