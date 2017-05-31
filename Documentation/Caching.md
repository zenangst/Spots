# Cache 

## View state caching

**Spots** features a view state cache. Instead of saving all your data in a database somewhere and perform queries every time to initiate a view controller, we went with a different and much simpler approach. If a **SpotsController** has a cache key and you call `save`, internally it will encode all underlaying **Component** objects and its children into a JSON file and store that to disk. The uniqueness of the file comes from the cache key, think of this like your screen identifier. The next time you construct a **SpotsController** with that cache key, it will try to load that from disk and display it the exact same way as it was before saving. The main benefit here is that you don’t have to worry about your object changing by updating to future versions of **Spots**.

**Component** also supports view state caching, this gives you fine-grained control over the information that you want cache.

View state caching is optional but we encourage you to use it, as it renders the need to use a database as optional.
