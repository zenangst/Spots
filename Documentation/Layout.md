# Layout

Configuring layout for different components can be tricky, Spots helps to solve this problem with a neat and tidy `Layout` struct that lives on `ComponentModel`. It is used to customize your UI related elements. It can set `sectionInset` and collection view related properties like `minimumInteritemSpacing` and `minimumLineSpacing`. It works great both programmatically and with JSON. It is supported on all three platforms.

```swift

/// Programmatic approach
let layout = Layout(
  span: 3.0,
  dynamicSpan: false,
  dynamicHeight: true,
  pageIndicatorPlacement: .below,
  itemSpacing: 1.0,
  lineSpacing: 1.0,
  inset: Inset(
    top    : 10,
    left   : 10,
    bottom : 10,
    right  : 10
  )
)

/// A layout built from JSON
let json = Layout(
  [
    "span" : 3.0,
    "dynamic-span" : false,
    "dynamic-height" : true,
    "page-indicator-placement" : "below",
    "item-spacing" : 1.0,
    "line-spacing" : 1.0,
    "inset" : [
      "top" : 10.0,
      "left" : 10.0,
      "bottom" : 10.0,
      "right" : 10.0
    ]
  ]
)
```
