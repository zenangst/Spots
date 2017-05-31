# Models

### ComponentModel

```swift
  public struct ComponentModel: Mappable {
  public var index = 0
  public var title = ""
  public var kind = ""
  public var span: CGFloat = 0
  public var items = [Item]()
  public var size: CGSize?
  public var meta = [String : String]()
}
```

- **.index**
Calculated value to determine the index it has inside of the component.
- **.title**
This is used as a title in table view view.
- **.kind**
Determines which component should be used. `carousel`, `list`, `grid` are there by default but you can register your own.
- **.span**
Determines the amount of views that should fit on one row, by default it is set to zero and uses the default flow layout to render collection based views.
- **.size**
Calculated value based on the amount of items and their combined heights.
- **.meta**
Custom data that you are free to use as you like in your implementation.

### Item

```swift
  public struct Item: Mappable {
  public var index = 0
  public var title = ""
  public var subtitle = ""
  public var image = ""
  public var kind = ""
  public var action: String?
  public var size = CGSize(width: 0, height: 0)
  public var meta = [String : AnyObject]()
}
```

- **.index**
Calculated value to determine the index it has inside of the model.
- **.title**
The headline for your data, in a `UITableViewCell` it is normally used for `textLabel.text` but you are free to use it as you like.
- **.subtitle**
Same as for the title, in a `UITableViewCell` it is normally used for `detailTextLabel.text`.
- **.image**
Can be either a URL string or a local string, you can easily determine if it should use a local or remote asset in your view.
- **.kind**
Is used for the `reuseIdentifier` of your `UITableViewCell` or `UICollectionViewCell`.
- **.action**
Action identifier for you to parse and process when a user taps on a list item. We recommend [Compass](https://github.com/hyperoslo/Compass) as centralized navigation system.
- **.size**
Can either inherit from the `UITableViewCell`/`UICollectionViewCell`, or be manually set by the height calculations inside of your view.
- **.meta**
This is used for extra data that you might need access to inside of your view, it can be a hex color, a unique identifer or additional images for your view.
