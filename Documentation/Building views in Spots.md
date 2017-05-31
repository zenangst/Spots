# Building views in Spots

## Working with views

To add your own view to **Spots**, you need the view to conform to **ItemConfigurable** which means that you have to implement `preferredViewSize` size property and the `configure(_ item: inout Item)` method. This is used to aggregate model data to your view. You register the view on `Configuration` by giving the view its own unique identifier.

We don’t like to dictate the terms of how you build your views, if you prefer to build them using `.nib` files, you should be free to do so, and with **Spots** you can. The only thing that differs is how you register the view on the component.

```swift
func configure(with item: Item)
func computeSize(for item: Item)
```

**preferredViewSize** is exactly what the name implies, it is the preferred size for the view when it should be rendered on screen. We used the prefix `preferred` as it might be different if the view has dynamic height.

Using different heights for different objects can be a hassle in iOS, tvOS and macOS, but not with **Spots**. To set a calculated height based on the **Item** content, you simply set the height back to the *item* when you are done calculating it in *configure(inout item: Item)*.

e.g
```swift
func configure(with item: Item) {
  textLabel.text = item.title
  textLabel.sizeToFit()
}

func computeSize(for item: Item) -> CGFloat {
  return CGSize(width: item.size.width,
                height: textLabel.frame.size.height)
}
```

**Item** is a struct, but because of the **inout** keyword in the method declaration it can perform mutation and pass that back to the data source. If you prefer the size to be static, you can simply not set the height and **Spots** will handle setting it for you based on the **preferredViewSize**.

When your view conforms to **ItemConfigurable**, you need to register it with a unique identifier for that view.

You register your view on the component that you want to display it in.

```swift
Configuration.register(view: MyAwesomeView.self, identifier: “my-awesome-view”)
```

For `nib`-based views, you register them like this.

```swift
Configuration.register(nib: UINib(nibName: "MyAwesomeView", bundle: .main), identifier: "my-awesome-view")
```

You can also register default views for your component, what it means is that it will be the fallback view for that view if the `identifier` cannot be resolved or the `identifier` is absent.

```swift
Configuration.register(defaultView: MyAwesomeView.self)
```

By letting the model data identifiers decide which views to use gives you the freedom of displaying anything anywhere, without cluttering your code with dirty if- or switch-statements that are hard to maintain.

## Working with headers and footers

Adding headers and footers is just as easy as adding regular views into your view hierarchy.
You register them in the same way on your `ComponentModel` by adding a header or footer item.
This way you get the same kind of functionality as if you were adding a regular view in your component.
The tl;dr is that you can display pretty much anything anywhere.

```swift
let header = Item(
  title: "My awesome header", 
  kind: "default-header-view"
)
let footer = Item(
  title: "Congrats, you made it to the end", 
  kind: "default-footer-view"
)
let component = ComponentModel(
  header: header,
  footer: footer
)
```
