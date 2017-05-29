# Getting started guide

This guide aims to show you how to start working with `Spots`. It will run through building a tiny application that displays a list of contacts, first as a normal `UITableView` and then we will gradually improve the application by adding an additional component to display information that we would deem more important and have that be displayed using an horizontal `UICollectionView`.

This is what we will end up with at the end of the guide:

<img src="https://github.com/zenangst/Spots/blob/326fd8d6433dce8c3b9f68e9872d98314974e37a/Documentation/Resources/getting-started-final-result.png?raw=true" height="250"/>

## Making views.

Lets build a small demo application called `MyContacts` to show what it is like to work with `Spots` in an application.

The first thing that we need to do is adapt and register your views so that `Spots` can resolve them.
To use views in `Spots`, they need to conform to `ItemConfigurable`. It is a very lean protocol that has two required methods. The first is `configure(with item: Item)`, this is where our view gets the model information so that we can properly set texts to your label etc. The second function is `computeSize(for item: Item) -> CGSize`. This is used to give back an appropriate size for the view. It could return a static value or be computed based of the content coming from the model.

Lets kick things of by making a `ContactView` that will be used to show contact information in a list.

```swift
import UIKit
import Spots

class ContactView: UIView, ItemConfigurable {

  lazy var titleLabel = UILabel()

  override init(frame: CGRect) {
    super.init(frame: frame)

    addSubview(titleLabel)
    setupConstraints()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupConstraints() {
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.heightAnchor.constraint(equalToConstant: 32).isActive = true
    titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
    titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
  }

  func configure(with item: Item) {
    titleLabel.text = item.title
  }

  func computeSize(for item: Item) -> CGSize {
    return CGSize(width: frame.size.width,
                  height: 44)
  }
}
```

## Registering a view.

Next up is to register the view in `Spots` so that it can be resolved and used when the `Component` will render its data. This is done early on in the applications life-cycle to ensure that all views are properly registered before trying to use them inside of a `Component`. This is really easy, you pass the views type and an identifier to `Configuration` and that's it.

```swift
Configuration.register(view: ContactView.self, identifier: "Contact")
```

You can also register a default view that will be used if the current identifier cannot be resolved. This is how we would register `ContactView` as the default in our application.

```swift
Configuration.registerDefault(view: ContactView.self)
```

## Creating a component model.

We now have to create some model data for our `Component`.
All components in `Spots` share the same data model, it is called `ComponentModel`. The `ComponentModel` is used as the data source for any UI object that will be used inside of `Spots`. Lets create a small component model to be used in our application.

```swift
let model = ComponentModel(kind: .list, items: [
  Item(title: "Sigvart Angel Hoel", kind: "Contact"),
  Item(title: "Mathias Benjaminsen", kind: "Contact"),
  Item(title: "Vasiliy Ermolovich", kind: "Contact"),
  Item(title: "Felipe Espinoza", kind: "Contact"),
  Item(title: "Epsen Høgbakk", kind: "Contact"),
  Item(title: "Tim Kurvers", kind: "Contact"),
  Item(title: "Damian Lopata", kind: "Contact"),
  Item(title: "Sindre Moen", kind: "Contact"),
  Item(title: "Torgeir Øverland", kind: "Contact"),
  Item(title: "Francesco Rodriguez", kind: "Contact"),
  Item(title: "Henriette Røseth", kind: "Contact"),
  Item(title: "Peter Sergeev", kind: "Contact"),
  Item(title: "John Terje Sirevåg", kind: "Contact"),
  Item(title: "Chang Xiangzhong", kind: "Contact")
])
```

One interesting thing to point out is the `kind`. In our case we want a simple `UITableView`, in `Spots` they are referred to as lists. `kind` can also be `grid` or `carousel`. When using `grid`, a `UICollectionView` will be used to render the component. The same goes for `.carousel`, but as the name implies, the user interaction and layout will be horizontal when using `.carousel` instead of `.grid`. Note that the views registered on `Spots` are not required to inherit from `UICollectionViewCell` or `UITableViewCell`. Internally they will be wrapped in either `ListWrapper` or `GridWrapper`.

## Creating a component.

We are almost there now, what we need next is a `Component` to hold the model. Because of `Component`'s polymorphic nature, there is only one `Component` class.
During `Component`'s initialization, it will either create a `UICollectionView` or `UITableView` as its view.

```swift
let component = Component(model: model)
```

That's all you need to do to create a `Component` with a `UITableView` as its rendering foundation.

## Creating a spots controller.

Next up is to create a controller that we can display on screen. Introducing the `SpotsController`. It is very much like a normal `UIViewController` as it doesn't really know what it is displaying, that is up to the `Component` to decide based of the model information given to it by `ComponentModel`.

```swift
let controller = SpotsController(components: [component])
```

## The result.

Because `SpotsController` is just like any other view controller, you display it in the exact same way as you would any other controller that you have in your application.
Lets wrap it in a `UINavigation` controller so that we get a nice navigation bar at the top.

This is what our `ApplicationDelegate` ended up looking like.

```swift
import UIKit
import Spots

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    Configuration.register(view: ContactView.self, identifier: "Contact")
    Configuration.registerDefault(view: ContactView.self)

    let window = UIWindow(frame: UIScreen.main.bounds)
    let model = ComponentModel(kind: .list, items: [
      Item(title: "Sigvart Angel Hoel", kind: "Contact"),
      Item(title: "Mathias Benjaminsen", kind: "Contact"),
      Item(title: "Vasiliy Ermolovich", kind: "Contact"),
      Item(title: "Felipe Espinoza", kind: "Contact"),
      Item(title: "Epsen Høgbakk", kind: "Contact"),
      Item(title: "Tim Kurvers", kind: "Contact"),
      Item(title: "Damian Lopata", kind: "Contact"),
      Item(title: "Sindre Moen", kind: "Contact"),
      Item(title: "Torgeir Øverland", kind: "Contact"),
      Item(title: "Francesco Rodriguez", kind: "Contact"),
      Item(title: "Henriette Røseth", kind: "Contact"),
      Item(title: "Peter Sergeev", kind: "Contact"),
      Item(title: "John Terje Sirevåg", kind: "Contact"),
      Item(title: "Chang Xiangzhong", kind: "Contact")
      ])
    let component = Component(model: model)
    let controller = SpotsController(components: [component])
    controller.title = "My contacts"
    let navigationController = UINavigationController(rootViewController: controller)

    window.backgroundColor = UIColor.white
    window.rootViewController = navigationController
    window.makeKeyAndVisible()

    self.window = window

    return true
  }
}
```

If we run the application, this is what we end up with.

<img src="https://github.com/zenangst/Spots/blob/326fd8d6433dce8c3b9f68e9872d98314974e37a/Documentation/Resources/getting-started-first-run.png?raw=true" height="350"/>

## Adding an additional component.

Right now the application doesn't really look like much, so lets add another component into the mix to see how that can improve on how the application looks and feels. If this were a real application, it would be nice to get a quick overview of contacts that were recently used. Lets add a carousel component at the top to see what that would look like.

Let's start by repeating some of our initial steps, so lets create a new view called `RecentContactView` and register it on `Spots`.

```swift
import UIKit
import Spots

class RecentContactView: UIView, ItemConfigurable {

  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 14)
    label.textColor = UIColor.darkGray
    label.numberOfLines = 2
    label.textAlignment = .center
    label.backgroundColor = .lightGray
    label.layer.cornerRadius = 4
    label.layer.masksToBounds = true
    return label
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    addSubview(titleLabel)
    setupConstraints()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupConstraints() {
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.heightAnchor.constraint(equalToConstant: 66).isActive = true
    titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
  }

  func configure(with item: Item) {
    titleLabel.text = item.title
  }

  func computeSize(for item: Item) -> CGSize {
    return CGSize(width: frame.size.width,
                  height: 77)
  }
}
```

As you can see, this view looks very similar to the `ContactView`. More work was put into the styling of the title label and it returns a different size. Let's go ahead and register this view on `Spots`.

```swift
Configuration.register(view: RecentContactView.self, identifier: "Recent")
```

Now we are ready to create a new `ComponentModel`.

```swift
let recentModel = ComponentModel(
  kind: .carousel,
  layout: Layout(span: 3.5, itemSpacing: 5, inset: Inset(padding: 5)),
  items: [
    Item(title: "Francesco Rodriguez", kind: "Recent"),
    Item(title: "Sindre Moen", kind: "Recent"),
    Item(title: "Sigvart Angel Hoel", kind: "Recent"),
    Item(title: "Torgeir Øverland", kind: "Recent"),
    ])
```

As you can see, we have added some additional properties to the model to configure it in the way that we want. To be more precise, we have giving the `ComponentModel` a layout property. Because this component is being displayed as a carousel it would be nice to indicate that there is more information available than is visible on screen. This is easily achieved by using the `span` property on `Layout`. What `span` does is to divide the `Component`'s parent views width by the `span` and uses that width for all items in the carousel. So what we are actually expressing here is that we would like the carousel to show three and a half items on screen. We also add a bit of spacing between the items by setting `itemSpacing` to 5. This translates into `minimumInteritemSpacing` on `UICollectionView`. And last but not least we add some spacing around the items by giving the layout some insets. The `Inset` object has values for all directions (top, left , bottom right). As you might have guessed, setting them will add additional padding in the direction that you want. Here we use a convenience initializer with the label `padding`, that will apply the same padding to all sides.

We are now ready to create an additional component for the new model.

```swift
let recentComponent = Component(model: recentModel)
```

And to add the `Component` to the controller we need to include it in the collection of components in the controllers initializer.

```swift
let controller = SpotsController(components: [recentComponent, contactsComponent])

```

Because we want `recentComponent` to be displayed before the `contactsComponent`, we simply just add it at the top and that is how it will be displayed on screen.

We are now ready to run the application again to take another peek at what our application looks like, but before we do, we want to make one additional configuration for the carousel component. Let's set the background for carousels in our application to use a light gray color to clearly show where one component ends and the other begins.

This is done by assigning a configuration closure on `Component`. It is a static closure that will be invoked during each `Component`'s setup method.

```swift
Component.configure = { component in
  switch component.model.kind {
  case .carousel:
    component.view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
  case .list:
    component.view.backgroundColor = .white
  default:
    break
  }
}
```

So now all list components will use a white background and all carousels will have a very light gray color.

This is what our newly refactored `AppDelegate.swift` looks like now.

```swift
import UIKit
import Spots

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    Configuration.register(view: ContactView.self, identifier: "Contact")
    Configuration.register(view: RecentContactView.self, identifier: "Recent")
    Configuration.registerDefault(view: ContactView.self)

    Component.configure = { component in
      switch component.model.kind {
      case .carousel:
        component.view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
      case .list:
        component.view.backgroundColor = .white
      default:
        break
      }
    }

    let window = UIWindow(frame: UIScreen.main.bounds)

    let recentModel = ComponentModel(
      kind: .carousel,
      layout: Layout(span: 3.5, itemSpacing: 5, inset: Inset(padding: 5)),
      items: [
        Item(title: "Francesco Rodriguez", kind: "Recent"),
        Item(title: "Sindre Moen", kind: "Recent"),
        Item(title: "Sigvart Angel Hoel", kind: "Recent"),
        Item(title: "Torgeir Øverland", kind: "Recent"),
        ])
    let recentComponent = Component(model: recentModel)

    let contactsModel = ComponentModel(kind: .list, items: [
      Item(title: "Sigvart Angel Hoel", kind: "Contact"),
      Item(title: "Mathias Benjaminsen", kind: "Contact"),
      Item(title: "Vasiliy Ermolovich", kind: "Contact"),
      Item(title: "Felipe Espinoza", kind: "Contact"),
      Item(title: "Epsen Høgbakk", kind: "Contact"),
      Item(title: "Tim Kurvers", kind: "Contact"),
      Item(title: "Damian Lopata", kind: "Contact"),
      Item(title: "Sindre Moen", kind: "Contact"),
      Item(title: "Torgeir Øverland", kind: "Contact"),
      Item(title: "Francesco Rodriguez", kind: "Contact"),
      Item(title: "Henriette Røseth", kind: "Contact"),
      Item(title: "Peter Sergeev", kind: "Contact"),
      Item(title: "John Terje Sirevåg", kind: "Contact"),
      Item(title: "Chang Xiangzhong", kind: "Contact")
      ])
    let contactsComponent = Component(model: contactsModel)
    let controller = SpotsController(components: [recentComponent, contactsComponent])
    controller.title = "My contacts"
    let navigationController = UINavigationController(rootViewController: controller)

    window.backgroundColor = UIColor.white
    window.rootViewController = navigationController
    window.makeKeyAndVisible()

    self.window = window
    return true
  }
```

<img src="https://github.com/zenangst/Spots/blob/326fd8d6433dce8c3b9f68e9872d98314974e37a/Documentation/Resources/getting-started-two-components.png?raw=true" height="350"/>

The application is starting to take shape but we could still use some more information to the describe what is shown to the users so lets do just that.

## Adding a header view.

Adding headers to a `Component` is just as easy as adding an additional item to a list.
Lets make one more view that can work as our header view in this application.

```swift
import UIKit
import Spots

class HeaderView: UIView, ItemConfigurable {

  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = .boldSystemFont(ofSize: 12)
    label.textColor = UIColor.darkGray.withAlphaComponent(0.5)
    label.numberOfLines = 2
    label.layer.cornerRadius = 4
    label.layer.masksToBounds = true
    return label
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    addSubview(titleLabel)
    setupConstraints()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupConstraints() {
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
    titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
    titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
  }

  func configure(with item: Item) {
    titleLabel.text = item.title
  }

  func computeSize(for item: Item) -> CGSize {
    return CGSize(width: frame.size.width,
                  height: 30)
  }
}
```

We register headers in the exact same way as you do any other view.

```swift
Configuration.register(view: HeaderView.self, identifier: "Header")
```

Now lets add it to the component models.

```swift
let recentModel = ComponentModel(
  header: Item(title: "Recent contacts".uppercased(), kind: "Header"),
  kind: .carousel,
  layout: Layout(span: 3.5, itemSpacing: 5, inset: Inset(left: 5, bottom: 5, right: 5)),
  items: [
    Item(title: "Francesco Rodriguez", kind: "Recent"),
    Item(title: "Sindre Moen", kind: "Recent"),
    Item(title: "Sigvart Angel Hoel", kind: "Recent"),
    Item(title: "Torgeir Øverland", kind: "Recent"),
])

let contactsModel = ComponentModel(
  header: Item(title: "Contacts".uppercased(), kind: "Header"),
  kind: .list,
  items: [
    Item(title: "Sigvart Angel Hoel", kind: "Contact"),
    Item(title: "Mathias Benjaminsen", kind: "Contact"),
    Item(title: "Vasiliy Ermolovich", kind: "Contact"),
    Item(title: "Felipe Espinoza", kind: "Contact"),
    Item(title: "Epsen Høgbakk", kind: "Contact"),
    Item(title: "Tim Kurvers", kind: "Contact"),
    Item(title: "Damian Lopata", kind: "Contact"),
    Item(title: "Sindre Moen", kind: "Contact"),
    Item(title: "Torgeir Øverland", kind: "Contact"),
    Item(title: "Francesco Rodriguez", kind: "Contact"),
    Item(title: "Henriette Røseth", kind: "Contact"),
    Item(title: "Peter Sergeev", kind: "Contact"),
    Item(title: "John Terje Sirevåg", kind: "Contact"),
    Item(title: "Chang Xiangzhong", kind: "Contact")
])
```

Note that we made some slight changes to the `Layout` object on `recentModel`. We removed the `top` inset to make the content fit nicely together with the header.

## The final result.

So our final version of `AppDelegate` ended up looking like this.

```swift
import UIKit
import Spots

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    Configuration.register(view: ContactView.self, identifier: "Contact")
    Configuration.register(view: RecentContactView.self, identifier: "Recent")
    Configuration.register(view: HeaderView.self, identifier: "Header")
    Configuration.registerDefault(view: ContactView.self)

    Component.configure = { component in
      switch component.model.kind {
      case .carousel:
        component.view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
      case .list:
        component.view.backgroundColor = .white
      default:
        break
      }
    }

    let window = UIWindow(frame: UIScreen.main.bounds)

    let recentModel = ComponentModel(
      header: Item(title: "Recent contacts".uppercased(), kind: "Header"),
      kind: .carousel,
      layout: Layout(span: 3.5, itemSpacing: 5, inset: Inset(left: 5, bottom: 5, right: 5)),
      items: [
        Item(title: "Francesco Rodriguez", kind: "Recent"),
        Item(title: "Sindre Moen", kind: "Recent"),
        Item(title: "Sigvart Angel Hoel", kind: "Recent"),
        Item(title: "Torgeir Øverland", kind: "Recent"),
        ])
    let recentComponent = Component(model: recentModel)

    let contactsModel = ComponentModel(
      header: Item(title: "Contacts".uppercased(), kind: "Header"),
      kind: .list,
      items: [
      Item(title: "Sigvart Angel Hoel", kind: "Contact"),
      Item(title: "Mathias Benjaminsen", kind: "Contact"),
      Item(title: "Vasiliy Ermolovich", kind: "Contact"),
      Item(title: "Felipe Espinoza", kind: "Contact"),
      Item(title: "Epsen Høgbakk", kind: "Contact"),
      Item(title: "Tim Kurvers", kind: "Contact"),
      Item(title: "Damian Lopata", kind: "Contact"),
      Item(title: "Sindre Moen", kind: "Contact"),
      Item(title: "Torgeir Øverland", kind: "Contact"),
      Item(title: "Francesco Rodriguez", kind: "Contact"),
      Item(title: "Henriette Røseth", kind: "Contact"),
      Item(title: "Peter Sergeev", kind: "Contact"),
      Item(title: "John Terje Sirevåg", kind: "Contact"),
      Item(title: "Chang Xiangzhong", kind: "Contact")
      ])
    let contactsComponent = Component(model: contactsModel)
    let controller = SpotsController(components: [recentComponent, contactsComponent])
    controller.title = "My contacts"
    let navigationController = UINavigationController(rootViewController: controller)

    window.backgroundColor = UIColor.white
    window.rootViewController = navigationController
    window.makeKeyAndVisible()

    self.window = window

    return true
  }
}
```

And when we run the application, this is what we see.

<img src="https://github.com/zenangst/Spots/blob/326fd8d6433dce8c3b9f68e9872d98314974e37a/Documentation/Resources/getting-started-final-result.png?raw=true" height="350"/>
