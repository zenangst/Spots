# JSON structure

## Why JSON?

JSON works great as a common transport language, it is platform agnostic and it is something that developers are already using regularly when building application that fetch data from an external resource. **Spots** uses JSON internally to save a snapshot of the view state to disk, the only thing that you have to do is to give the **SpotsController** a cache key and call save whenever you have performed your update.

So what if I don't have a backend that supports **Spots** view models? Not to worry, you can set up **Spots** programmatically and still use all the other advantages of the framework.

## An example JSON

```json
{
   "components":[
      {
         "header":{
          "title":"Hyper iOS",
          "kind":"HeaderView"
         },
         "kind":"list",
         "layout":{
           "span":"1"
         },
         "items":[
            {
               "title":"John Hyperseed",
               "subtitle":"Build server",
               "image":"{image url}",
               "type":"profile",
               "action":"profile:1",
               "meta":{
                  "nationality":"Apple"
               }
            },
            {
               "title":"Vadym Markov",
               "subtitle":"iOS Developer",
               "image":"{image url}",
               "type":"profile",
               "action":"profile:2",
               "meta":{
                  "nationality":"Ukrainian"
               }
            },
            {
               "title":"John Sundell",
               "subtitle":"iOS Developer",
               "image":"{image url}",
               "type":"profile",
               "action":"profile:3",
               "meta":{
                  "nationality":"Swedish"
               }
            },
            {
               "title":"Khoa Pham",
               "subtitle":"iOS Developer",
               "image":"{image url}",
               "type":"profile",
               "action":"profile:4",
               "meta":{
                  "nationality":"Vietnamese"
               }
            },
            {
               "title":"Christoffer Winterkvist",
               "subtitle":"iOS Developer",
               "image":"{image url}",
               "type":"profile",
               "action":"profile:5",
               "meta":{
                  "nationality":"Swedish"
               }
            }
         ]
      }
   ]
}
```

### View models in the Cloud
```swift
let controller = SpotsController(json)
navigationController?.pushViewController(controller, animated: true)
```

The JSON data will be parsed into view model data and your view controller is ready to be presented, it is just that easy.

### Programmatic approach
```swift
let contactModel = ComponentModel(
  header: Item(title: "Contacts"), 
  items: [
    Item(title: "John Hyperseed"),
    Item(title: "Vadym Markov"),
    Item(title: "John Sundell"),
    Item(title: "Khoa Pham"),
    Item(title: "Christoffer Winterkvist")
  ]
)
let component = Component(model: contactModel)
let controller = SpotsController(components: [component])

navigationController?.pushViewController(controller, animated: true)
```
